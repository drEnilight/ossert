# frozen_string_literal: true

namespace :ossert do
  desc 'Invoke data updates for stale projects'
  task :refresh_data do
    require './config/sidekiq.rb'
    Ossert::Workers::RefreshFetch.perform_async
  end
end
