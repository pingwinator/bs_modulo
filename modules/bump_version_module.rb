
module BumpVersionModule
  extend self
  
  def run runner
    unless runner.config['bump_version']
      puts 'skipping...'
      return true
    end
    
    puts "Bumping version..."
    
    system "agvtool bump -all"
    version_number = `agvtool vers -terse`.strip
    system "agvtool new-marketing-version '#{version_number}'"
    puts "Push updated version numbers to git"
    system "git commit -am \"AUTOBUILD -- configuration: #{runner.config['run']['configuration']}, ver: #{version_number}\""
    system "git push origin #{runner.config['branch']}"
    
    true
  end
end
