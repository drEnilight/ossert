# frozen_string_literal: true

require './config/sidekiq.rb'

namespace :ossert do
  namespace :refresh do
    desc 'Refresh StackOverflow data for all projects'
    task :stackoverflow do
      Ossert::Workers::PartialRefreshFetch.perform_async(:StackOverflow)
    end

    desc 'Refresh Rubygems data for all projects'
    task :rubygems do
      Ossert::Workers::PartialRefreshFetch.perform_async(:Rubygems)
    end

    desc 'Refresh GitHub data for all projects'
    task :github do
      Ossert::Workers::PartialRefreshFetch.perform_async(:GitHub)
    end

    desc 'Refresh Bestgems data for all projects'
    task :bestgems do
      Ossert::Workers::PartialRefreshFetch.perform_async(:Bestgems)
    end
  end
end
