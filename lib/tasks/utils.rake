require 'descriptive_statistics'
require 'pp'
require 'table_print'

def git_branch
  `git rev-parse --abbrev-ref HEAD`.strip
end

def analyze_file(file_path)
  duration_regex = /duration=(\d+\.*\d*)/
  db_regex = /db=(\d+\.*\d*)/
  requests = []
  db = []
  ruby = []
  File.open(file_path, "r") do |file_handle|
    puts "[#{file_path}] Parsing..."
    file_handle.each_line do |l|
      d = 0
      total = nil
      if match = l.scan(duration_regex).last
        requests << (total=match.last.to_f)
      end
      if match = l.scan(db_regex).last
        db << (d=match.last.to_f)
      end
      if total
        ruby << (total-d)
      end
    end
  end
  data = requests.descriptive_statistics.merge(percentile_90th: requests.percentile(90), percentile_95th: requests.percentile(95), percentile_99th: requests.percentile(99))
  data.merge!({db_mean: db.mean})
  name = file_path.scan(/log\/#{Rails.env}\.(\w+)/).last.last
  data.merge!({name: name})
  data.merge!({ruby_mean: ruby.mean})
  puts "[#{file_path}] ...Done."
  data
end

namespace :data do
  desc "Truncate the #{git_branch} log file and remove stackprof results."
  task clear: :environment do
    `> #{Rails.root}/log/#{Rails.env}.#{git_branch}.log`
    `rm -Rf #{Rails.root}/tmp/stackprof_#{git_branch}`
  end

  desc "Delete all log files and stacprof results."
  task clear_all: :environment do
    `rm #{Rails.root}/log/*.log`
    `rm -Rf #{Rails.root}/tmp/stackprof_*`
  end
  
  desc "Analyze the #{git_branch} branch log file and output results."
  task log: :environment do
    rows = []
    f = "log/#{Rails.env}.#{git_branch}.log"
    rows << analyze_file(f)
    tp rows, :name, :number, :mean, :ruby_mean, :db_mean, :percentile_90th, :percentile_95th, :percentile_99th, :max
  end

  desc "Analyze all log files and output results."
  task logs: :environment do
    files = Dir.glob("log/#{Rails.env}.*.log")
    puts "Analyzing #{files.size} files."
    rows = []
    files.each do |f|
      rows << analyze_file(f)
    end # files.each
    tp rows, :name, :number, :mean, :ruby_mean, :db_mean, :percentile_90th, :percentile_95th, :percentile_99th, :max
  end

  desc "Generate stackprof results for the #{git_branch} branch."
  task :stackprof do
    dir = "tmp/stackprof_#{git_branch}"
    name = if dir.include?('newrelic')
            'newrelic'
           elsif dir.include?('scout')
            'scoutapm'
           end
    results = `stackprof -l1000 #{dir}/* | grep -i #{name}`
  end
end # data

namespace :bench do
  desc "Switch to the provided branch ('b' env var if provided), grab the latest, clear data, and start unicorn."
  task :prep do
    `git checkout #{ENV['b']}` if ENV['b']
    `git pull`
    Rake::Task["data:clear"].invoke
    Rake::Task["unicorn:start"].invoke
  end
end

