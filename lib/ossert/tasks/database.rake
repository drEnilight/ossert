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

  desc 'Create the database, load the schema, and initialize with the seed data (db:reset to also drop the db first)'
  task :setup do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:load_config'].invoke

    Sequel::Migrator.run(DB, File.expand_path('../../../db/migrate', __dir__))
    Rake::Task['db:version'].execute
  end

  desc 'Dumps the database to backups'
  task :dump, [:fmt] do |_, args|
    dump_fmt = args.fmt || 'c' # or 'p', 't', 'd'
    dump_sfx = suffix_for_format dump_fmt
    backup_dir = backup_directory true
    cmd = nil
    with_config do |app, db_url|
      file_name = Time.now.strftime('%Y%m%d%H%M%S') + '_' + app + '_db.' + dump_sfx
      cmd = "pg_dump #{db_url} --no-owner --no-acl -F #{dump_fmt} -v -f #{backup_dir}/#{file_name}"
    end
    puts cmd
    sh cmd do
      # Ignore errors
    end
  end

  desc 'Show the existing database backups'
  task :list_backups do
    backup_dir = backup_directory
    puts backup_dir.to_s
    exec "/bin/ls -lht #{backup_dir}"
  end

  desc 'Restores the database from a backup using PATTERN'
  task :restore, [:pat] do |_, args|
    puts 'Please pass a pattern to the task' unless args.pat.present?
    cmd = nil
    with_config do |_, db_url|
      cmd = command_for_files args.pat, db_url
    end
    unless cmd.nil?
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      puts cmd
      exec "#{cmd} || exit 0"
    end
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
