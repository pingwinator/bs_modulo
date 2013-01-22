
module UploadDoaModule
  extend self
  
  def run runner
    puts 'Uploading build...'
    
    ipa_file  = runner.config.runtime.ipa_file
    info_file = runner.config.runtime.build_dir + runner.config.runtime.app_file_name + '.app/Info.plist'
    url       = runner.config.doa.host + 'upload/' + runner.config.doa.guid
    system %Q[plutil -convert xml1 #{info_file}]
    result  = JSON.parse(post(url, {}, {
      :info => info_file,
      :ipa  => ipa_file
    }))
    
    unless result["result"]
      puts result["message"]
      return false
    end
    
    true
  end
end
