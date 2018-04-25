# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

  desc 'Show the existing database backups'
  task :list_backups do
    backup_dir = backup_directory
    puts backup_dir.to_s
    exec "/bin/ls -lht #{backup_dir}"
  end
end
