# config valid for current version and patch releases of Capistrano
lock "~> 3.10.0"

set :application, "flatreader"
set :repo_url, "git@github.com:ckahle33/flatreader.git"
set :user, "ckahle33"

set :deploy_to, "/home/ubuntu/flatreader"

set :chruby_ruby, 'ruby-2.4.0'
set :passenger_restart_with_touch, true

set :linked_files, ["config/database.yml", ".env"]

set :ssh_options, {
  forward_agent: "true" ,
  user: fetch(:user),
  auth_methods: ["publickey"],
  keys: ["/Users/cpk/.ssh/flatreader.pem"]
}
