
require 'yaml'

#Utilities
class Utils
	
	def self.which(program)
		p = ENV['PATH'].split(":").each{ |p| break "#{p}/#{program}" if File.executable?("#{p}/#{program}")}
		return p unless p == ENV['PATH'].split(':')
		return false
	end

	def self.getdir(path)
		(path.split('/') - [path.split('/').last]).join('/')
	end

	def self.getfile(path)
		path.split('/').last
	end

end

#Global definitions

iso_url = ENV['URL'] || "http://download.grml.org/grml64-small_2013.02.iso"
iso_path = ENV['ISO'] || Utils.getfile(iso_url)
squashfs = ENV['SQUASHFS'] || "iso-build-dir/live/grml64-small/grml64-small.squashfs"
squashfs_dir = Utils.getdir(squashfs)
squashfs_root = squashfs_dir + "/squashfs-root"

dependencies = ['7z', 'unsquashfs', 'mksquashfs', 'wget', 'chroot']
isocmd = Utils.which('mkisofs') || Utils.which('genisoimage')

#Start Task definitions
task :default do
	puts "Show Help here"
end

desc "Check if required software is installed"
task :check_dependencies do
	r=dependencies.each do |d|
		break d unless Utils.which d
	end
	fail "Please install #{r}" unless r == dependencies
	fail "Please install mkisofs or genisoimage" unless isocmd
end

desc "Do all the unpacking"
task :unpack => ['check_dependencies'] do
	Rake::Task['ISO:unpack'].invoke
	Rake::Task['ISO:unsquashfs'].invoke
end

desc "Copy/create requred files and install software"
task :build => ['check_dependencies'] do
	Rake::Task['ISO:grub_timeout'].invoke
	Rake::Task['CHROOT:prepare'].invoke
	Rake::Task['CHROOT:chroot'].invoke
	Rake::Task['CHROOT:clean'].invoke
	Rake::Task['CHROOT:cp_mk'].invoke
	Rake::Task['CHROOT:mk_init'].invoke
	Rake::Task['ISO:add_version'].invoke
end

desc "Do all the repacking"
task :repack => ['check_dependencies'] do
	Rake::Task['ISO:mksquashfs'].invoke
	Rake::Task['ISO:rm_squashfs_root'].invoke
	Rake::Task['ISO:repack'].invoke
end



namespace 'ISO' do


	directory 'iso-build-dir'	

	desc "Download the Original ISO - (Use ENV['URL'] to specify custom URL)"
	task :download do
		sh "wget #{iso_url}"
	end

	desc "Unpack Original ISO (Use ENV['ISO'] to specify custom Filename)"
	task :unpack => ["iso-build-dir"] do
		sh "7z x -oiso-build-dir #{iso_path}"
	end

	desc "Pack content of iso-build-dir to bootable ISO"
	task :repack do
#	 	sh "#{isocmd} -l -J -R -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -A 'Razor Microkernel' -sysid 'LINUX' -o grml_mk.iso iso-build-dir"
		sh "#{isocmd} -quiet -l -J -R -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -A 'Razor Microkernel' -sysid 'LINUX' -V 'Razor MK' -o rz_mk.iso iso-build-dir"

	end

	desc "Unpack squashfs image from ISO (use ENV['SQUASHFS'] to specify custom path)"
	task :unsquashfs do
		sh "unsquashfs -d #{squashfs_root} #{squashfs}"
	end

	desc "Pack squashfs-root"
	task :mksquashfs do
		sh "mksquashfs #{squashfs_root} #{squashfs} -noappend -comp xz -b 262144"
	end

	desc "Remove squashfs-root directory (ATTENTION: Make sure no Filesystems are mounted inside! Maybe run CHROOT:clean)"
	task :rm_squashfs_root do
		rm_rf squashfs_root
	end

	desc "Change Bootloader Timeout"
	task :grub_timeout do
		sh "sed -i.bak 's/set timeout=20/set timeout=3/' iso-build-dir/boot/grub/header.cfg"
	end

	desc "add ISO version file"
	task :add_version do
		iso_version = ENV['VER'] || "0.1"
		mk_version_hash = Hash.new
                mk_version_hash['mk_version'] = iso_version
                mk_version_filename = squashfs_root + File::SEPARATOR + 'tmp' + File::SEPARATOR + 'mk-version.yaml'
                File.open(mk_version_filename, 'w') { |file|
                        YAML::dump(mk_version_hash, file)
                }
	end

end

namespace 'CHROOT' do

	desc "Copy hosts /etc/resolv.conf to chroot"
	task :resolvconf do
		mv "#{squashfs_root}/etc/resolv.conf", "#{squashfs_root}/tmp/resolv.conf"
		cp "/etc/resolv.conf", "#{squashfs_root}/etc/resolv.conf"	
	end

	desc "Restore original resolv.conf in chroot"
	task :undo_resolvconf do
		mv "#{squashfs_root}/tmp/resolv.conf", "#{squashfs_root}/etc/resolv.conf"
	end

	desc "Copy Microkernel scripts"
	task :cp_mk do
		sh "cp *.rb #{squashfs_root}/usr/local/bin/"
		cp_r "razor_microkernel", "#{squashfs_root}/usr/lib/ruby/1.8/"
		cp "conf/mk_conf.yaml", "#{squashfs_root}/tmp/mk_conf.yaml"
		cp "conf/first_checkin.yaml", "#{squashfs_root}/tmp/first_checkin.yaml"
		cp "etc/init.d/dhcp", "#{squashfs_root}/etc/init.d/dhcp"
		cp "usr/share/udhcpc/dhcp_mk_config.script", "#{squashfs_root}/etc/udhcpc/"
	end

	desc "Generate chroot-script from conf/gem.list and conf/package.list"
	task :chroot_script do
		File.open("#{squashfs_root}/tmp/chroot.sh", "w+") do |file|
			file.write "\#!/bin/bash\n"
			file.write "apt-get update\n"
			file.write "apt-get install -y #{File.open("conf/package.list", 'r').each_line.to_a.join(" ").delete("\n")}\n"
      file.write "gem install --no-rdoc --no-ri #{File.open("conf/gem.list", 'r').each_line.to_a.join(" ").delete("\n")}\n"
			file.write "apt-get clean\n"
			file.write "rm -rf /var/lib/apt/lists\n"
		end
		sh "chmod 755 #{squashfs_root}/tmp/chroot.sh"
	end

	desc "Execute chroot-script in chroot"
	task :chroot => ['chroot_script'] do
		sh "chroot #{squashfs_root} /tmp/chroot.sh"
	end

	desc "Remove chroot script"
	task :rm_chroot_script do
		rm "#{squashfs_root}/tmp/chroot.sh"
	end

	desc "Configure rz_mk autostart"
	task :mk_init do
		File.open("#{squashfs_root}/etc/init.d/bootlocal.last", "a+") do |file|
			file.write "# initialize the Microkernel and start a few key services\n\n"
			file.write "/bin/hostname box\n"
			if ENV['DEBUG'] == "yes"
				file.write "/etc/init.d/ssh start\n"
			end
			file.write "/usr/local/bin/rz_mk_init.rb\n"
		end
	end

	desc "Mount special filesystems for chroot"
	task :mounts do
		sh "mount -t proc proc #{squashfs_root}/proc"
		sh "mount -t sysfs sys #{squashfs_root}/sys"
		sh "mount -o bind /dev #{squashfs_root}/dev"
		sh "mount -t devpts devpts #{squashfs_root}/dev/pts"
	end
	
	desc "Unmount special chroot filesystems"
	task :umounts do
		sh "umount #{squashfs_root}/dev/pts"
		sh "umount #{squashfs_root}/dev"
		sh "umount #{squashfs_root}/sys"
		sh "umount #{squashfs_root}/proc"
	end
	
	desc "Prepare chroot environment"
	task :prepare do
		Rake::Task['CHROOT:resolvconf'].invoke
		Rake::Task['CHROOT:chroot_script'].invoke
		Rake::Task['CHROOT:mounts'].invoke
	end

	desc "Clean chroot environment"
	task :clean do
		Rake::Task['CHROOT:umounts'].invoke
		Rake::Task['CHROOT:rm_chroot_script'].invoke
		Rake::Task['CHROOT:undo_resolvconf'].invoke
	end
end
