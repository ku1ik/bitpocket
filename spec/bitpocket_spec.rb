require 'fileutils'

def sync
  system "[ -d .sinck ] || mkdir .sinck"
  system "[ -f .sinck/tree-prev ] || touch .sinck/tree-prev"
  system "find | sort | grep -v ./.sinck | grep -v '^\.$' > .sinck/tree-current"
  system "comm -23 .sinck/tree-prev .sinck/tree-current | cut -d '/' -f 2- >.sinck/fetch-exclude"
  system "comm -13 .sinck/tree-prev .sinck/tree-current | cut -d '/' -f 2- >>.sinck/fetch-exclude"
  system "rsync -auvzxi --delete --exclude .sinck --exclude-from .sinck/fetch-exclude ../remote/ ."
  system "rsync -auvzxi --delete --exclude .sinck . ../remote/"
  system "rm .sinck/tree-current"
  system "find | sort | grep -v ./.sinck | grep -v '^\.$' > .sinck/tree-prev"
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

describe 'bitpocket' do
  before(:all) do
    @tmp_dir = "/tmp/bitpocket-test-#{Time.now.to_i}"
    @test_case = { :num => 0 }
  end

  before do
    @test_case[:num] += 1
    test_case_dir = File.join(@tmp_dir, @test_case[:num].to_s)
    @local_dir = File.join(test_case_dir, 'local')
    @remote_dir = File.join(test_case_dir, 'remote')
    FileUtils.mkdir_p(@local_dir)
    FileUtils.mkdir_p(@remote_dir)
    Dir.chdir(@local_dir)
  end

  it 'does not remove new local files' do
    touch local_path('a')
    sync
    File.exist?(local_path('a')).should be(true)
  end

  it 'does not bring back removed local files' do
    touch local_path('a')
    touch remote_path('a')
    sync
    rm local_path('a')
    sync
    File.exist?(local_path('a')).should be(false)
  end

  describe 'creating new local file' do
    before do
      touch local_path('a')
    end

    it 'transfers new file from local to remote' do
      sync

      File.exist?(local_path('a')).should be(true)
      File.exist?(remote_path('a')).should be(true)
    end
  end

  describe 'updating local file' do
    let(:content) { 'foo' }

    before do
      touch local_path('a')
      touch remote_path('a')
      sync
      cat content, local_path('a')
    end

    it 'transfers updated file from local to remote' do
      sync

      File.read(local_path('a')).should == content
      File.read(remote_path('a')).should == content
    end
  end

  describe 'creating new remote file' do
    before do
      touch remote_path('a')
    end

    it 'transfers new file from remote to local' do
      sync

      File.exist?(local_path('a')).should be(true)
      File.exist?(remote_path('a')).should be(true)
    end
  end

  describe 'updating remote file' do
    let(:content) { 'foo' }

    before do
      touch local_path('a')
      touch remote_path('a')
      sync
      cat content, remote_path('a')
    end

    it 'transfers updated file from remote to local' do
      sync

      File.read(local_path('a')).should == content
      File.read(remote_path('a')).should == content
    end
  end

  describe 'deleting local file' do
    before do
      touch local_path('a')
      touch remote_path('a')
      sync
      rm local_path('a')
    end

    it 'removes file from remote' do
      sync

      File.exist?(local_path('a')).should be(false)
      File.exist?(remote_path('a')).should be(false)
    end
  end

  describe 'deleting remote file' do
    before do
      touch local_path('a')
      touch remote_path('a')
      sync
      rm remote_path('a')
    end

    it 'removes file from local' do
      sync

      File.exist?(local_path('a')).should be(false)
      File.exist?(remote_path('a')).should be(false)
    end
  end
end
