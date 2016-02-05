def git_branch
  `git rev-parse --abbrev-ref HEAD`.strip
end

namespace :data do
  task clear: :environment do
    `rm #{Rails.root}/log/#{Rails.env}.#{git_branch}.log`
    `rm -Rf #{Rails.root}/tmp/stackprof_#{git_branch}`
  end
  task clear_all: :environment do
    `rm #{Rails.root}/log/*.log`
    `rm -Rf #{Rails.root}/tmp/stackprof_*`
  end
end

namespace :bench do
  task :prep do
    `git checkout #{ENV['b']}` if ENV['b']
    `git pull`
    Rake::Task["data:clear"].invoke
    Rake::Task["unicorn:start"].invoke
  end
end