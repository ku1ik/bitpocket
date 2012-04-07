# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :cli => "-f progress --color", :binstubs => true do
  watch(%r{^spec/.+_spec\.rb$})
  watch('bin/bitpocket') { 'spec' }
end
