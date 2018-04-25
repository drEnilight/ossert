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

  namespace :restore do
    desc 'Restores the database from latest backup'
    task :last do
      cmd = nil
      with_config do |_, db_url|
        file = Dir.glob("#{backup_directory}/*").max_by { |f| File.mtime(f) }
        if file
          fmt = format_for_file file
          if fmt.nil?
            puts "No recognized dump file suffix: #{file}"
          else
            cmd = "pg_restore -d '#{db_url}' -F #{fmt} -v #{file}"
          end
        else
          puts 'No backups found'
        end
      end
      unless cmd.nil?
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        puts cmd
        exec "#{cmd} || exit 0"
      end
    end
  end
end
