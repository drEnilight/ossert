# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  task :load_config do
    DB = Sequel.connect(ENV.fetch('DATABASE_URL'))
  end
end
