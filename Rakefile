
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
	Rake::Task['ISO:resolvconf'].invoke
end

desc "Copy/create requred files and install software"
task :build => ['check_dependencies'] do
	Rake::Task['ISO:cp_mk'].invoke
	Rake::Task['ISO:install_packages'].invoke
	Rake::Task['ISO:install_gems'].invoke
	Rake::Task['ISO:grub_timeout'].invoke
	if ENV['DEBUG'] == "yes"
		Rake::Task['debug_enable']
	end
end

desc "Do all the repacking"
task :repack => ['check_dependencies'] do
	Rake::Task['ISO:undo_resolvconf'].invoke
	Rake::Task['ISO:mksquashfs'].invoke
	Rake::Task['ISO:repack'].invoke
end



namespace 'ISO' do

	iso_url = ENV['URL'] || "http://download.grml.org/grml64-small_2013.02.iso"
	iso_path = ENV['ISO'] || Utils.getfile(iso_url)
	squashfs = ENV['SQUASHFS'] || "iso_build_dir/live/grml64-small/grml64-small.squashfs"
	squashfs_dir = Utils.getdir(squashfs)

	directory 'iso_build_dir'	

	desc "Download the Original ISO - (Use ENV['URL'] to specify custom URL)"
	task :download do
		sh "wget #{iso_url}"
	end

	desc "Unpack Original ISO (Use ENV['ISO'] to specify custom Filename)"
	task :unpack => ["iso_build_dir"] do
		sh "7z x -oiso_build_dir #{iso_path}"
	end

	desc "Pack content of iso_build_dir to bootable ISO"
	task :repack do
	 	sh "#{isocmd} -l -J -R -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -A 'Razor Microkernel' -sysid 'LINUX' -o grml_mk.iso iso_build_dir"
	end

	desc "Unpack squashfs image from ISO (use ENV['SQUASHFS'] to specify custom path)"
	task :unsquashfs do
		sh "unsquashfs #{squashfs} -d #{squashfs_dir}/squashfs-root"
	end

	desc "Pack squashfs-root"
	task :mksquashfs do
		sh "mksquashfs #{squahsfs_dir}/squashfs-root #{squashfs} -noappend -comp xz -b 262144"
	end

	desc "Copy hosts /etc/resolv.conf to chroot"
	task :resolvconf do
		mv "#{squashfs_dir}/squashfs-root/etc/resolv.conf", "#{squashfs_dir}/squashfs-root/tmp/resolv.conf"
		cp "/etc/resolf.conf", "#{squashfs_dir}/squashfs-root/etc/resolv.conf"	
	end

	desc "Restore original resolv.conf in chroot"
	task :undo_resolvconf do
		mv "#{squashfs_dir}/squashfs-root/tmp/resolv.conf", "#{squashfs_dir}/squashfs-root/etc/resolv.conf"
	end

	desc "Copy Microkernel scripts"
	task :cp_mk do

	end

	desc "Install required packages as listed in packages.list"
	task :install_packages do

	end

	desc "Istall required gems as listed in gems.list"
	task :install_gems do

	end

	desc "Change Bootloader Timeout"
	task :grub_timeout do

	end

	desc "Build debug image"
	task :debug_enable do
		#enable ssh
		#request ssh-public-key
	end

	desc "add ISO version file"
	task :add_version do
		iso_version = ENV['VER'] || "0.1"
		mk_version_hash = Hash.new
                mk_version_hash['mk_version'] = iso_version
                mk_version_filename = squashfs_dir + File::SEPARATOR + 'tmp' + File::SEPARATOR + 'mk-version.yaml'
                File.open(mk_version_filename, 'w') { |file|
                        YAML::dump(mk_version_hash, file)
                }
	end

end

