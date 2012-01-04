require 'spec_helper'

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
    FileUtils.mkdir_p("#{@local_dir}/.bitpocket")
    cat 'REMOTE=../remote', local_path('.bitpocket/config')
  end

  let(:content) { 'foo' }

  it 'does not sync ignored files' do
    cat "/a\n/b", local_path('.bitpocket/exclude')
    touch local_path('a')
    touch remote_path('b')

    sync

    local_path('a').should exist
    remote_path('a').should_not exist
    local_path('b').should_not exist
    remote_path('b').should exist
  end

  it 'does not sync .bitpocket dir' do
    sync

    remote_path('.bitpocket').should_not exist
  end

  it 'does not remove new local files' do
    touch local_path('a')

    sync

    local_path('a').should exist
  end

  it 'does not remove new local files created in parallel to previous sync' do
    sync(:callback => :add_after)
    sync

    local_path('after').should exist
  end

  it 'does not bring back removed local files' do
    touch local_path('a')
    touch remote_path('a')
    sync
    rm local_path('a')

    sync

    local_path('a').should_not exist
  end

  it 'does not bring back removed local files deleted in parallel to previous sync' do
    touch local_path('after')
    sync
    sync(:callback => :remove_after)
    sync

    local_path('after').should_not exist
  end

  it 'transfers new file from local to remote' do
    touch local_path('a')

    sync

    local_path('a').should exist
    remote_path('a').should exist
  end

  it 'transfers updated file from local to remote' do
    touch local_path('a')
    touch remote_path('a')
    sync
    system "touch -d '00:00' #{remote_path('a')}"
    cat content, local_path('a')

    sync

    File.read(local_path('a')).should == content
    File.read(remote_path('a')).should == content
  end

  it 'transfers new file from remote to local' do
    touch remote_path('a')

    sync

    local_path('a').should exist
    remote_path('a').should exist
  end

  it 'transfers updated file from remote to local' do
    touch local_path('a')
    touch remote_path('a')
    sync
    cat content, remote_path('a')

    sync

    File.read(local_path('a')).should == content
    File.read(remote_path('a')).should == content
  end

  it 'removes file from remote if locally deleted' do
    touch local_path('a')
    touch remote_path('a')
    sync
    rm local_path('a')

    sync

    local_path('a').should_not exist
    remote_path('a').should_not exist
  end

  it 'removes file from local if remotely deleted' do
    touch local_path('a')
    touch remote_path('a')
    sync
    rm remote_path('a')

    sync

    local_path('a').should_not exist
    remote_path('a').should_not exist
  end
end
