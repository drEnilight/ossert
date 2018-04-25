# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  desc 'Create the database, load the schema, and initialize with the seed data (db:reset to also drop the db first)'
  task :setup do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:load_config'].invoke

    Sequel::Migrator.run(DB, File.expand_path('../../../../db/migrate', __dir__))
    Rake::Task['db:version'].execute
  end
end
