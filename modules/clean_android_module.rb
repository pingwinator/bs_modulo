
class CleanAndroidModule < BaseModule
  config_key 'build_android'
  
  def self.run config
    info "Cleaning..."
    gradle = config.build_android.gradle
    if gradle 
      properties_file = real_file sysconf.android.properties_file
      keystores_path = real_dir sysconf.android.keystore_dir
      if properties_file
        properties = YAML.load_file(properties_file) if File.exists? properties_file
        props = properties[config.build_android.properties_key] if properties
        props['key.store'] = keystores_path + props['key.store'] if defined?(props['key.store'])
      end
      
      if props
        if gradle 
          info 'Updating gradle.properties file...'
          project_props_file = config.runtime.project_dir + 'gradle.properties'
        end
        project_props = nil
        if File.exists? project_props_file
          project_props = Properties.load_from_file project_props_file
        else
          project_props = Properties.new []
        end
        project_props.gradle
        project_props.set props
        project_props.save_to_file project_props_file
      end
      config.runtime.gradlew_path = config.runtime.workspace + config.build_android.main_gradle_path
      system %Q[sh #{config.runtime.gradlew_path}/gradlew clean -p=#{config.runtime.gradlew_path} -Poutput_file=#{config.runtime.apk_file}] or fail "clean project"
    else  
    # clean deps
     deps      = config.build_android.dependencies
     workspace = config.runtime.workspace
     if deps && !deps.empty?
       deps.each do |dep|
         path = workspace + dep
         FileUtils.cd path do
           system %Q[ant clean] if File.exists? 'build.xml' or fail "clean dependency #{dep}"
         end
       end
     end
     
     # clean project
     FileUtils.cd config.runtime.project_dir do
       system %Q[ant clean] or fail "clean project"
     end
   end
  end
end
