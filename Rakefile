
task :default do
	puts "Show Help here"
end

task :check_dependencies do
end

def which(program)
ENV['PATH'].split(":").each{ |p| break "#{p}/#{program}" if File.executable?("#{p}/#{program}")}
end


namespace 'ISO' do

	iso_url = ENV['URL'] || "http://download.grml.org/grml64-small_2013.02.iso"
	iso_path = ENV['ISO'] || ENV['URL'].split("/").last || "grml64-small_2013.02.iso"
	squashfs_dir = ENV['SQUASHFSDIR'] || "iso_build_dir/live/grml64-small"

	directory 'iso_build_dir'	

	task :download do

	end

	task :unpack => ["iso_build_dir"] do
		sh "7z x -oiso_build_dir #{iso_path}"
	end

	task :repack do
	 	sh "genisoimage -l -J -R -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -A 'Razor Microkernel' -sysid 'LINUX' -o grml_mk.iso iso_build_dir"
	end

	task :unsquashfs do
		sh "unsquashfs #{squashfs_dir}/*.sqashfs -d #{squashfs_dir}/squashfs-root"
	end

	task :mksquashfs do
		sh "mksquashfs #{squahsfs_dir}/squashfs-root grml64-small.squashfs -noappend -comp xz -b 262144"
	end

	file :resolvconf do
		mv "#{squashfs_dir}/squashfs-root/etc/resolv.conf", "#{squashfs_dir}/squashfs-root/tmp/resolv.conf"
		cp "/etc/resolf.conf", "#{squashfs_dir}/squashfs-root/etc/resolv.conf"	
	end

	file :undo_resolvconf do

	end

	task :cp_mk do

	end

	task :install_packages do

	end

	task :debug_enable do
		#enable ssh
		#request ssh-public-key
	end
end

class Utils
	
	def self.which(program)
		ENV['PATH'].split(":").each{ |p| break "#{p}/#{program}" if File.executable?("#{p}/#{program}")}
	end

end
