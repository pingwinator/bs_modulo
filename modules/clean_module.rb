
class CleanModule < BaseModule
  config_key 'clean'
  defaults :enabled => true
  check_enabled!
  
  def self.run config
    info "Cleaning build dir..."
    rm_rf "#{config.runtime.project_dir}/build/"
  end
end
