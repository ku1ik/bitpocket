require "rspec/core/rake_task"

module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

RSpec::Core::RakeTask.new(:tests) do |t|
  t.rspec_opts = %w{--colour}
end

task :default => :tests
