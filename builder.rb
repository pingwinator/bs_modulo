#!/usr/bin/env ruby -KU
# encoding: UTF-8

__F__ = if File.symlink? __FILE__ then File.readlink(__FILE__) else File.expand_path(__FILE__) end
BUILDER_DIR = File.expand_path(File.dirname(__F__)) + '/'
$:.unshift "#{BUILDER_DIR}lib/"
require "constants"
require "helpers"
require "runner"
require "settings"
require 'commander/import'

program :name, 'builder'
program :version, '1.0.1'
program :description, 'Build System'

command :install do |c|
  c.syntax = ' builder install'
  c.description = 'Install builder in system'
  c.option '-f', '--force', 'Force install'
  c.action do |args, options|
    if File.exist?(BIN_PATH) && !options.force
      fail "builder is already installed or its default name '#{BIN_PATH}' is already taken by another app\nyou can overwrite it by passing --force option"
    elsif options.force
      begin
        File.delete BIN_PATH
      rescue Exception => e
        fail "failed while deleting old file/link at #{BIN_PATH}..."
      end
    end
    puts 'Installing...'
    puts "...creating [#{BIN_PATH}] symlink..."
    File.symlink __F__, BIN_PATH
    puts "...creating global configuration file [#{GLOBAL_CONFIG_FILE}]..."
    open(GLOBAL_CONFIG_FILE, "w") { |io|  io << ''} unless File.exist? GLOBAL_CONFIG_FILE
    puts 'Done.'
  end
end

command :build do |c|
  c.syntax = '[WORKSPACE=/path/to/project] [CONFIGURATION=configuration_name] builder build [build_config_file]'
  c.description = 'Run build'
  c.action do |args, options|
    Runner::run args
  end
end

command :branch do |c|
  c.syntax = '[WORKSPACE=/path/to/project] [BRANCH=branch_name] builder build'
  c.description = 'Switch to BRANCH and fetch all data' 
  c.action do |args, options|
    ## check input parameters
    if ENV['BRANCH']
      branch = ENV['BRANCH']
    else
      branch = 'master'
    end

    if ENV['WORKSPACE']
      workspace = real_dir ENV['WORKSPACE']
    else
      workspace = real_dir Dir::pwd
    end

    if File.exist?(workspace + '.git') 
      command = %Q[git reset --hard && git clean -f -d && git fetch origin && git checkout #{branch} && git reset --hard origin/#{branch} && git clean -f -d]
      info command
      result = system command
    else 
      info %Q[branch skipped]
    end
  end
end

# just for tests
# ENV['WORKSPACE'] = '/Users/macuser/Projects/LifelikeClassifieds'
# ENV['CONFIGURATION'] = 'ui_tests'
# Runner::run ['builder.yml']
