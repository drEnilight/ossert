# frozen_string_literal: true

require 'ossert/tasks/helpers/database_task_helper'

namespace :db do
  include DatabaseTaskHelper

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
end
