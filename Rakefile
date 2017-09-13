# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

task(:default).clear
task :env_test { sh('. credentials/.env_test') }
task default: %i[env_test spec rubocop]
