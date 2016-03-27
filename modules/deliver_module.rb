

class DeliverModule < BaseModule
  config_key 'deliver'
  defaults :enabled => false
  check_enabled!
  
  # required self.run function with config parameter
  def self.run config
    info 'Deviler module...'
    # try to read default apple id and team id from keychain profile
    properties_file = real_file sysconf.xcode.properties_file
    if properties_file
      properties = YAML.load_file(properties_file) if File.exists? properties_file
      props = properties[config.profile.identity] if properties
      if props
        team_id = props['team_id']
        apple_id =  props['apple_id']
      end
    end
    #read apple id and team id builder.yml if and override if exist
    team_id = config.deliver.team_id if config.deliver.team_id
    apple_id = config.deliver.apple_id if config.deliver.apple_id
    ipa_file = config.runtime.ipa_file
    parameters = [
        %Q[-k "#{team_id}"],
        %Q[-u "#{apple_id}"],
        %Q[--ipa "#{ipa_file}"],
        %Q[--skip_metadata],
        %Q[--skip_screenshots]]

    params = parameters.join(' ')
    info params
    if team_id.nil? || apple_id.nil? || ipa_file.nil?
      fail %Q[Deliver module failed, check parameters for deliver: #{params}]
    end
    result = system %Q[deliver #{params}]
     unless result
       fail "Deliver: upload failed"
    end
    
  end
end
