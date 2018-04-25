# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  desc 'Prints current schema version'
  task :version do
    db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    puts "Schema Version: #{current_version(db)}"
  end
end
