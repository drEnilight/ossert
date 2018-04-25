# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  task :create do
    create_db(URI(ENV.fetch('DATABASE_URL')))
  end

  task migrate: :load_config do
    Sequel::Migrator.run(DB, File.expand_path('../../../../db/migrate', __dir__))
    Rake::Task['db:version'].execute
  end

  task rollback: :load_config do
    if (version = current_version).positive?
      Sequel::Migrator.run(
        DB,
        File.expand_path('../../../../db/migrate', __dir__),
        target: version - ENV.fetch('STEP', 1).to_i
      )
    end

    Rake::Task['db:version'].execute
  end

  task :drop do
    drop_db(URI(ENV.fetch('DATABASE_URL')))
  end
end
