## Build System

#### Requirements
Ruby 1.9.3+ --  checkout [rvm.io](https://rvm.io/)  
Bundler gem -- `gem install bundler`  
xctool - [https://github.com/facebook/xctool](https://github.com/facebook/xctool)

#### Install

	git clone https://github.com/dev4dev/bs_modulo.git
	cd bs_modulo
	bundle install
	./builder.rb install
	# add needed content to created ~/.bs_modulo.yml file (see exemples/global.yml file)
	# check that /usr/local/bin is in your $PATH var

#### Usage
Execute command in project directory (where builder.yml file is located)

	WORKSPACE=/project/dir CONFIGURATION=configuration_name builder build [builder.yml]

Usage [documentation](https://github.com/dev4dev/bs_modulo/blob/master/docs/USAGE.md).  
Module's config params [documentation](https://github.com/dev4dev/bs_modulo/blob/master/docs/CONFIGURATION.md).
