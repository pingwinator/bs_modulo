
module BranchModule
  extend self
  
  def run config

    branch_name = config.branch.name
    puts "Switch to branch #{branch_name}...";
    system %Q[git checkout #{branch_name}]
    system %Q[git pull origin #{branch_name}]
    if config.branch.submodules?
      FileUtils.cd config.runtime.workspace do
        system %Q[git submodule update --init]
      end
    end

    true
  end
end
