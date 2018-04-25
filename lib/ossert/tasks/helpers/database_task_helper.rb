# frozen_string_literal: true

require 'sequel'
require 'uri'

module DatabaseTaskHelper
  Sequel.extension :migration

  def backup_directory(create = false, backup_dir = 'db/backups')
    if create && !Dir.exist?(backup_dir)
      puts "Creating #{backup_dir} .."
      FileUtils.mkdir_p(backup_dir)
    end
    backup_dir
  end

  def create_db(uri)
    database_name = uri.path.split('/').last
    sh "createdb #{db_opts(uri)} #{database_name}"
  end

  def command_for_files(pattern, db_url)
    files = Dir.glob("#{backup_directory}/*#{pattern}*")
    case files.size
    when 0
      puts "No backups found for the pattern '#{pattern}'"
    when 1
      command_for_file files.first, db_url
    else
      puts "Too many files match the pattern '#{pattern}': #{files.join("\n ")} "
      puts 'Try a more specific pattern'
    end
  end

  def command_for_file(file, db_url)
    return puts("No recognized dump file suffix: #{file}") unless (fmt = format_for_file(file)).present?
    "pg_restore -d '#{db_url}' -F #{fmt} -v -c #{file}"
  end

  def current_version
    DB.tables.include?(:schema_info) && DB[:schema_info].first[:version] || 0
  end

  def drop_db(uri)
    database_name = uri.path.split('/').last
    sh "dropdb #{db_opts(uri)} --if-exists #{database_name}"
  end

  def db_opts(uri)
    ["-h #{uri.host}"].tap do |opts|
      opts << "-U #{uri.user}" if uri.user
    end.join(' ')
  end

  def format_for_file(file)
    case file
    when /\.dump$/ then 'c'
    when /\.sql$/  then 'p'
    when /\.dir$/  then 'd'
    when /\.tar$/  then 't'
    end
  end

  def rebuild_db
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
  end

  def suffix_for_format(suffix)
    case suffix
    when 'c' then 'dump'
    when 'p' then 'sql'
    when 't' then 'tar'
    when 'd' then 'dir'
    end
  end

  def with_config
    yield 'ossert', ENV.fetch('DATABASE_URL')
  end
end
