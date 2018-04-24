# frozen_string_literal: true

namespace :ossert do
  desc 'Collect reference projects'
  task :collect_referencies do
    puts 'Run collecting process'
    time = Benchmark.realtime do
      ::Ossert.init
      ::Project.db.transaction do
        Ossert::Project.cleanup_referencies!
        reference_projects = Ossert::Reference.prepare_projects!
        Ossert::Reference.process_references(reference_projects)
      end
    end
    puts "Collecting process finished in #{time.round(3)} sec."
  end
end
