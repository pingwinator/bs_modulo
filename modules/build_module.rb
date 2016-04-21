require "xcodeproj"

class BuildModule < BaseModule
  config_key 'build'
  defaults :doclean => true, :enabled => true, :build_with_gym => false
  build_profile real_file('~/Library/MobileDevice/Provisioning Profiles/build.mobileprovision')
  build_profiles_dir real_dir('~/Library/MobileDevice/Provisioning Profiles')
  tmp_dir  ENV['TMPDIR']+'buildprofile_'+Time.now.to_i.to_s
  check_enabled!
  
  def self.run config
    info 'Building project...'
    
    project_name = self.project_name(config)
    unless check_build_configuration project_name, config.build.configuration
      fail %Q[Build configuration "#{config.build.configuration}" not found in project "#{config.build.project.name}"]
    end
    
    self.unlock_keychain config
    self.copy_provision_profile config
    
    
    ## building
    #command = %Q[xctool #{self.build_params config}]
    if config.build.build_with_gym?
      info 'Building using gym...'
      unless check_export_options_file(config)
        fail %Q[Export options file "export.plist" doesn't found]
      end
      command = %Q{gym #{self.gym_build_params config} | tee "$TMPDIR/buildLog.txt"}
    else
      info 'Building using xcodebuild...'
      command = %Q[set -o pipefail && xcodebuild #{self.build_params config} | tee "$TMPDIR/buildLog.txt" | xcpretty --no-utf]
    end
    
    #info command
    info "Run command: #{command}"
    result = system command
    ## done building
    
    if config.build.build_with_gym?
      config.runtime.ipa_file = config.runtime.project_dir + "build/build.ipa"
      config.runtime.dsym_file = config.runtime.project_dir + "build/build.dSYM.zip"

      puts "Paths: IPA: #{config.runtime.ipa_file}\n dSYM: #{config.runtime.dsym_file}"
    end
    
    hook! :build_complete
    unless result
       info "full build log"
       system %Q[cat "$TMPDIR/buildLog.txt"]
       fail "Build failed"
    end
  end
  
  private
  def self.check_build_configuration project_name, configuration_name
    begin
      project = Xcodeproj::Project.open(project_name)
    rescue
      project = Xcodeproj::Project.new(project_name)
    end
    configurations = project.build_configurations.map(&:name)
    configurations.include? configuration_name
  end
  
  def self.check_export_options_file config
    File.exists? "#{config.runtime.project_dir}export.plist"
  end
  
  def self.project_name config
    if config.using_pods?
      workspace = Xcodeproj::Workspace.new_from_xcworkspace "#{config.build.workspace.name}.xcworkspace"
      project_name = workspace.schemes[config.build.workspace.scheme]
      unless project_name
        fail %Q[Scheme "#{config.build.workspace.scheme}" not found]
      end
    else
      project_name = "#{config.build.project.name}.xcodeproj"
    end
    project_name
  end
  
  def self.build_params config
    build_parameters = [
      %Q[-configuration "#{config.build.configuration}"],
      %Q[-sdk "#{config.build.sdk}"],
      %Q[CODE_SIGN_IDENTITY="#{config.profile.identity}"],
      %Q[CONFIGURATION_BUILD_DIR="#{config.runtime.build_dir}"],
      (%Q[clean] if config.build.doclean?),
      %Q[build]
    ]
    if config.using_pods?
      ## build workspace
      build_parameters.unshift %Q[-workspace "#{config.build.workspace.name}.xcworkspace"]
      build_parameters.unshift %Q[-scheme "#{config.build.workspace.scheme}"]
    else
      build_parameters.unshift %Q[-project "#{config.build.project.name}.xcodeproj"]
      build_parameters.unshift %Q[-scheme "#{config.build.project.target}"]
    end
    
    build_parameters.join(' ')
  end
  
  def self.gym_build_params config
    build_parameters = [
      %Q[-w "#{config.build.workspace.name}.xcworkspace"],
      %Q[-s "#{config.build.workspace.scheme}"],
      %Q[-n build],
      %Q[-q "#{config.build.configuration}"],
      %Q[-a],
      %Q[--use_legacy_build_api],
      %Q[-i #{config.profile.identity}],
      %Q[-o "#{config.runtime.project_dir}build/"],
      (%Q[-c] if config.build.doclean?),
      %Q[build]
    ]

    build_parameters.join(' ')
  end
  
  ## provision profile
  def self.copy_provision_profile config
    if config.profile.file
      profile_file  = real_file config.profile.file
      mv(build_profiles_dir, tmp_dir)
      mkdir(build_profiles_dir)
      cp(profile_file, build_profile) if File.exists?(profile_file) && File.file?(profile_file)
      extra_files = config.profile.extra_files
      if extra_files
          extra_files.each do |extra_file|
              widget_file_dropbox = real_file extra_file
              cp(widget_file_dropbox, build_profiles_dir) if File.exists?(widget_file_dropbox)
          end
      end
      rollback = proc {
          info "swith to default profiles"
          self.remove_provision_profile
        }
        hook :failed, rollback
        hook :complete, rollback
    end
  end

  def self.unlock_keychain config
    properties_file = real_file sysconf.xcode.properties_file
    if properties_file
      properties = YAML.load_file(properties_file) if File.exists? properties_file
      props = properties[config.profile.identity] if properties
      if props
        keychain_file  =  sysconf.xcode.keychain_dir + props['keychain']
        info "Unlock keychain #{keychain_file}..."
        system %Q[security unlock-keychain -p #{props['password']} #{keychain_file}] or fail "failed unlock #{props['keychain']}"
        system %Q[security default-keychain -s #{keychain_file}] or fail "failed switch keychain"
        system %Q[security list-keychains -s #{keychain_file}] or fail "failed switch keychain"

        rollback = proc {
          info "swith to default keychain"
          system %Q[security lock-keychain  #{keychain_file}] 
          system %Q[security default-keychain -s login.keychain] or fail "failed switch keychain"
          system %Q[security list-keychains -s login.keychain] or fail "failed switch keychain"
        }
        hook :failed, rollback
        hook :complete, rollback
      end
    end
  end
  
  def self.remove_provision_profile
    rm_f build_profile if File.exists? build_profile
    rm_rf build_profiles_dir
    mv(tmp_dir, build_profiles_dir)
  end
  
end
