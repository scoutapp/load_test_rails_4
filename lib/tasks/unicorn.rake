namespace :unicorn do
  task :start do
    `unicorn -c config/unicorn.rb`
  end
  desc "Gracefully stop Unicorn."
  task :stop do
    pid = `cat tmp/unicorn.pid`
    `kill -QUIT #{pid}`
  end
end