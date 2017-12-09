namespace :deploy do
  task :setup_db do
    roles(:all) do
      within "#{current_path}" do
        execute :rake, "db:create RACK_ENV=production"
        execute :rake, "db:migrate RACK_ENV=production"
        execute :rake, "db:seed RACK_ENV=production"
      end
    end
  end
end

