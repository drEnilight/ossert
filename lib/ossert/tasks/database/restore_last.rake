# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

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
        rebuild_db
        puts cmd
        exec "#{cmd} || exit 0"
      end
    end
  end
end
