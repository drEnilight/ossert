# frozen_string_literal: true

namespace :ossert do
  namespace :cache do
    desc 'Reset data cache'
    task :reset do
      ::Ossert.init
      ::Classifier.dataset.delete
      Ossert::Classifiers::Growing.new.train
      true
    end
  end
end
