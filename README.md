## Build System

#### Requirements
Ruby 1.9.3+ --  checkout [rvm.io](https://rvm.io/)  
Bundler gem -- `gem install bundler`  

#### Install

	git clone git@github.com:pingwinator/bs_modulo.git
	cd bs_modulo
	bundle install
	./builder.rb install
	# add needed content to created ~/.bs_modulo.yml file (see exemples/global.yml file)
	# check that /usr/local/bin is in your $PATH var

#### Usage
Execute command in project directory (where builder.yml file is located)

	BRANCH=master WORKSPACE=/project/dir CONFIGURATION=configuration_name builder build [builder.yml]

Usage [documentation](http://gitlab.postindustria.com/backend/mobile-build-system/blob/master/docs/USAGE.md).  
Module's config params [documentation](http://gitlab.postindustria.com/backend/mobile-build-system/blob/master/docs/CONFIGURATION.md).
