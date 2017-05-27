require 'fileutils'

BP_BIN_PATH = File.join(File.dirname(__FILE__), '..', 'bin', 'bitpocket')
RSYNC_STUB_BIN_PATH = File.join(File.dirname(__FILE__), 'bin')
PATH = "#{RSYNC_STUB_BIN_PATH}:#{ENV['PATH']}"

def sync(opts={})
  # Plato Wu,2017/05/27: cygwin path contain spaces, it is ng
  system "bash -c 'CALLBACK=#{opts[:callback]} PATH=#{RSYNC_STUB_BIN_PATH}:$PATH bash #{BP_BIN_PATH}' >/dev/null"
#  system "bash -c 'CALLBACK=#{opts[:callback]} PATH=#{PATH} bash #{BP_BIN_PATH}' >/dev/null"
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

def mkdir(path)
  FileUtils.mkdir_p(path)
end

def rm(path)
  FileUtils.rm(path)
end

def mv(a, b)
  FileUtils.mv(a, b)
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

TEST_CASE = { :num => 0 }

shared_context 'setup' do
  before(:all) do
    @tmp_dir = "/tmp/bitpocket-test-#{Time.now.to_i}"
  end

  before do
    TEST_CASE[:num] += 1
    test_case_dir = File.join(@tmp_dir, TEST_CASE[:num].to_s)
    @local_dir = File.join(test_case_dir, 'local')
    @remote_dir = File.join(test_case_dir, 'remote')
    FileUtils.mkdir_p(@local_dir)
    FileUtils.mkdir_p(@remote_dir)
    Dir.chdir(@local_dir)
    FileUtils.mkdir_p("#{@local_dir}/.bitpocket")
    cat "REMOTE_PATH=#{@remote_dir}", local_path('.bitpocket/config')
  end

  let(:content) { 'foo' }
end
