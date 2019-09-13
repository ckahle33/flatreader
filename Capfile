# Load DSL and set up stages
require "capistrano/setup"
require "capistrano/deploy"
require "capistrano/scm/git"
require "capistrano/chruby"
require "capistrano/bundler"
require 'capistrano/rails/migrations'
require "capistrano/passenger"

install_plugin Capistrano::SCM::Git


Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
