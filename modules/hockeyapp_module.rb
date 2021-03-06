
class HockeyappModule < BaseModule
  config_key 'hockeyapp'
  check_enabled!
  
  def self.run config
    url = "https://rink.hockeyapp.net/api/2/apps/#{config.hockeyapp.app_id}/app_versions"
    headers = {
      "X-HockeyAppToken" => config.hockeyapp.token
    }
    params = {
      :notify => config.hockeyapp.notify? ? 1 : 0,
      :status => config.hockeyapp.download? ? 2 : 1
    }
    
    notes = ENV['BUILD_NOTES'] || ''
    unless notes.empty?
      params[:notes] = notes
      params[:notes_type] = 1
    end
    
    case config.platform
      when 'ios'
        files = {
          :ipa => config.runtime.ipa_file
        }
        
        files[:dsym] = config.runtime.dsym_file unless config.runtime.dsym_file.nil?
        
      when 'osx'
        files = {
          :ipa => config.runtime.zip_file
        }
        
        files[:dsym] = config.runtime.dsym_file unless config.runtime.dsym_file.nil?
        
      when 'android'
        apk_file = config.runtime.apk_file
        if config.project_name
          build_dir = File.dirname(config.runtime.apk_file) + '/'
          version = if config.runtime.version?
            '_ver_' + config.runtime.version
          else
            ''
          end
          apk_nice_name = build_dir + config.project_name + "_#{config.runtime.branch}_#{config.runtime.configuration}_" + version + '.apk'
          cp config.runtime.apk_file, apk_nice_name
          apk_file = apk_nice_name
        end
        files = {
          :ipa => apk_file
        }
    end
    
    result = post(url, params, files, headers)
    if result.code != 201
      obj     = JSON.parse(result)
      errors  = obj['errors']
      message = ["Errors:\n"]
      obj['errors'].each_pair do |k, v|
        message << "#{k}: #{v}"
      end
      info message.join "\n"
      return false
    else
      info result
    end
  end
end
