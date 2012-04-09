require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:tests) do |t|
  t.rspec_opts = %w{--colour}
end

task :default => :tests
