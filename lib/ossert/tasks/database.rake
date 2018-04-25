# frozen_string_literal: true

require 'uri'

namespace :db do
  desc 'Prints current schema version'
  task :version do
    puts "Schema Version: #{current_version}"
  end

  task :load_config do
    DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
  end

  desc 'Show the existing database backups'
  task :list_backups do
    backup_dir = backup_directory
    puts backup_dir.to_s
    exec "/bin/ls -lht #{backup_dir}"
  end


end
