# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  namespace :test do
    task :prepare do
      uri = URI(ENV.fetch('TEST_DATABASE_URL'))
      drop_db(uri)
      create_db(uri)
      DB = Sequel.connect(uri.to_s)
      Sequel::Migrator.run(DB, File.expand_path('../../../../db/migrate', __dir__))
      Rake::Task['db:version'].execute
    end
  end
end
