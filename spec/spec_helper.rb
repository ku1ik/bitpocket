require 'fileutils'

BP_BIN_PATH = File.join(File.dirname(__FILE__), '..', 'bin', 'bitpocket')
RSYNC_STUB_BIN_PATH = File.join(File.dirname(__FILE__), 'bin')
PATH = "#{RSYNC_STUB_BIN_PATH}:#{ENV['PATH']}"

def sync(opts={})
  system "CALLBACK=#{opts[:callback]} PATH=#{PATH} sh #{BP_BIN_PATH} >/dev/null"
end

def local_path(fname)
  "#{@local_dir}/#{fname}"
end

def remote_path(fname)
  "#{@remote_dir}/#{fname}"
end

def touch(path)
  FileUtils.touch(path)
end

def cat(content, path)
  File.open(path, 'w') { |f| f.write content }
end

def rm(path)
  FileUtils.rm(path)
end

RSpec::Matchers.define :exist do |attribute|
  match do |filename|
    File.exist?(filename)
  end
end
