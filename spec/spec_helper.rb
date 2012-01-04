require 'fileutils'

BP_BIN_PATH = File.join(File.dirname(__FILE__), '..', 'bin', 'bitpocket')
RSYNC_STUB_BIN_PATH = File.join(File.dirname(__FILE__), 'bin')
PATH = "#{RSYNC_STUB_BIN_PATH}:#{ENV['PATH']}"

def sync(opts={})
  system "CALLBACK=#{opts[:callback]} PATH=#{PATH} sh #{BP_BIN_PATH} >/dev/null"
  $?.exitstatus
end

def local_path(fname)
  "#{@local_dir}/#{fname}"
end

def remote_path(fname)
  "#{@remote_dir}/#{fname}"
end

def touch(path)
  FileUtils.mkdir_p(File.dirname(path))
  FileUtils.touch(path)
end

def cat(content, path)
  FileUtils.mkdir_p(File.dirname(path))
  File.open(path, 'w') { |f| f.write content }
end

def rm(path)
  FileUtils.rm(path)
end

RSpec::Matchers.define :exist do
  match do |filename|
    File.exist?(filename)
  end
end

RSpec::Matchers.define :succeed do
  match do |status|
    status == 0
  end
end

RSpec::Matchers.define :exit_with do |expected|
  match do |status|
    status == expected
  end
end
