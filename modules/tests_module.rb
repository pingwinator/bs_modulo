
class TestsModule < BaseModule
  config_key 'tests'
  check_enabled!
  
  def self.run config
    info 'Running tests...'
    system %Q[killall -m -KILL "iPhone Simulator"]
    
    parameters = [
      "-scheme #{config.tests.scheme}",
      '-sdk iphonesimulator',
      "clean build test",
      '-destination "platform=iOS Simulator,name=iPhone Retina (4-inch)"'
    ]
    if config.using_pods?
      parameters.unshift %Q[-workspace "#{config.build.workspace.name}.xcworkspace"]
    else
      parameters.unshift %Q[-project "#{config.build.project.name}.xcodeproj"]
    end
    cmd = %Q[set -o pipefail && xcodebuild #{parameters.join(' ')} | xcpretty --no-utf -r junit -o test-reports/junit-report.xml]
    info cmd
    result = system cmd 
    unless result
      fail "Unit tests failed"
    end
  end
end
