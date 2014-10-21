class UiTestsModule < BaseModule
  config_key 'ui_tests'
  check_enabled!

  @build_dir = '/tmp/UITests'
  @automation_results_dir = './automation_results'
  @junitReports_dir = './test-reports'

  def self.run config
    info 'Running ui tests...'

    # remove previous junit reports
    self.recreateDir @junitReports_dir

    parameters = [
        "-scheme #{config.ui_tests.scheme}",
        "-configuration #{config.build.configuration}",
        "-sdk iphonesimulator",
        "CONFIGURATION_BUILD_DIR=#{@build_dir}",
        "TARGETED_DEVICE_FAMILY=#{config.ui_tests.device_family}",
        "clean build"
    ]
    if config.using_pods?
      parameters.unshift %Q[-workspace "#{config.build.workspace.name}.xcworkspace"]
    else
      parameters.unshift %Q[-project "#{config.build.project.name}.xcodeproj"]
    end

    cmd = %Q[set -o pipefail && xcodebuild #{parameters.join(' ')} | tee "$TMPDIR/buildLog.txt" | xcpretty --no-utf]

    info 'build project for ui tests...'
    result = system cmd
    if result
      devices = config.ui_tests.devices.split(',')
      devices.each do |device|
        self.test_ui device, config.ui_tests.scheme, config.ui_tests.script_path
      end
    else
      self.testsFailed
    end
  end

  def self.test_ui device, app_name, script_path, should_retry_once = true
    openSimulator

    # remove previous plist reports
    self.recreateDir @automation_results_dir

    parameters = [
        "-v",
        "-t Automation.tracetemplate",
        %Q[-w "#{device}"],
        "-D #{@automation_results_dir}/Trace",
        "#{@build_dir}/#{app_name}.app",
        "-e UIARESULTSPATH #{@automation_results_dir}",
        %Q[-e UIASCRIPT "#{script_path}"]
    ]
    cmd = %Q[set -o pipefail && instruments #{parameters.join(' ')} | tee "$TMPDIR/buildLog.txt" | xcpretty --no-utf]

    info %Q[run instruments for ui tests on "#{device}"...]
    result = system cmd
    if result
      self.createReport device
    elsif should_retry_once
      # we will make one retry
      self.test_ui device, app_name, script_path, false
    else
      self.testsFailed
    end
  end

  def self.recreateDir dir
    FileUtils.rm_r dir if Dir.exists? dir
    FileUtils.mkdir_p dir
  end

  def self.createReport device
    uia2junit = File.join(File.dirname(__FILE__), '../resources/uia2junit')
    plistReportPath = %Q["#{@automation_results_dir}/Run 1/Automation Results.plist"]
    junitReportPath = %Q["#{@junitReports_dir}/junit-report #{device}.xml"]
    system %Q[set -o pipefail && #{uia2junit} #{plistReportPath} #{junitReportPath}]
  end

  def self.testsFailed
    info "full build log"
    system %Q[cat "$TMPDIR/buildLog.txt"]
    fail "UI tests failed"
  end

end