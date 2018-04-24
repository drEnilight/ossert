# frozen_string_literal: true

namespace :ossert do
  desc 'Add or replace project name exception'
  task :exception, [:name, :github_name] do |_, args|
    raise 'Arguments name and GitHub name expected' unless args.name.present? && args.github_name.present?
    if NameException.find(args.name)
      exceptions_repo.update(
        args.name,
        name: args.name,
        github_name: args.github_name
      )
    else
      NameException.create(
        name: args.name,
        github_name: args.github_name
      )
    end
    puts "Exception '#{args.name}' => '#{args.github_name}' saved!"
  end
end
