
class BuildAndroidModule < BaseModule
  config_key 'build_android'
  
  def self.run config
    info 'Building project...'
    gradle = config.build_android.gradle
    
    ## update ant.properties
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
      else 
        info 'Updating ant.properties file...'
        project_props_file = config.runtime.project_dir + 'ant.properties'
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
    
    ## build
    if gradle
      if File.exists? config.runtime.project_dir + "result.apk"
        config.runtime.apk_file = config.runtime.project_dir + "result.apk"
      else
        config.runtime.apk_file = config.runtime.project_dir + "build/outputs/apk/result.apk"
      end
      config.runtime.gradlew_path = config.runtime.workspace + config.build_android.main_gradle_path
      system %Q[sh #{config.runtime.gradlew_path}/gradlew #{config.build_android.gradle_params} -Poutput_file=#{config.runtime.apk_file}] or fail "build project"
    else
      system %Q[ant #{config.build_android.configuration}] or fail "build project"
    end  
   
  end
end
