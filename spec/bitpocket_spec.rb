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
    cat "REMOTE_PATH=#{@remote_dir}", local_path('.bitpocket/config')
  end

  let(:content) { 'foo' }

  it "exits with status 1 when other instance is running" do
    cat $$, local_path('.bitpocket/tmp/lock')

    sync.should exit_with(1)
  end

  it "exits with status 2 when stale lock found" do
    max_pid = File.read('/proc/sys/kernel/pid_max').to_i
    cat max_pid, local_path('.bitpocket/tmp/lock')

    sync.should exit_with(2)
  end

  it "exits with status 3 when can't acquire remote lock" do
    touch remote_path('.bitpocket/tmp/lock')

    sync.should exit_with(3)
  end

  it 'should release local lock after successful sync' do
    sync.should succeed

    local_path('.bitpocket/tmp/lock').should_not exist
  end

  it 'should release remote lock after successful sync' do
    sync.should succeed

    remote_path('.bitpocket/tmp/lock').should_not exist
  end

  it 'does not sync ignored files' do
    cat "/a\n/b", local_path('.bitpocket/exclude')
    touch local_path('a')
    touch remote_path('b')

    sync.should succeed

    local_path('a').should exist
    remote_path('a').should_not exist
    local_path('b').should_not exist
    remote_path('b').should exist
  end

  it 'does not sync .bitpocket dir' do
    sync.should succeed

    remote_path('.bitpocket').should_not exist
  end

  it 'does not remove new local files' do
    touch local_path('a')

    sync.should succeed

    local_path('a').should exist
  end

  it 'does not remove new local files created in parallel to previous sync' do
    sync(:callback => :add_after).should succeed
    sync.should succeed

    local_path('after').should exist
  end

  it 'does not bring back removed local files' do
    touch local_path('a')
    touch remote_path('a')
    sync.should succeed
    rm local_path('a')

    sync.should succeed

    local_path('a').should_not exist
  end

  it 'does not bring back removed local files deleted in parallel to previous sync' do
    touch local_path('after')
    sync.should succeed
    sync(:callback => :remove_after).should succeed
    sync.should succeed

    local_path('after').should_not exist
  end

  it 'transfers new file from local to remote' do
    touch local_path('a')

    sync.should succeed

    local_path('a').should exist
    remote_path('a').should exist
  end

  it 'transfers updated file from local to remote' do
    touch local_path('a')
    touch remote_path('a')
    sync.should succeed
    system "touch -d '00:00' #{remote_path('a')}"
    cat content, local_path('a')

    sync.should succeed

    File.read(local_path('a')).should == content
    File.read(remote_path('a')).should == content
  end

  it 'transfers new file from remote to local' do
    touch remote_path('a')

    sync.should succeed

    local_path('a').should exist
    remote_path('a').should exist
  end

  it 'transfers updated file from remote to local' do
    touch local_path('a')
    touch remote_path('a')
    sync.should succeed
    cat content, remote_path('a')

    sync.should succeed

    File.read(local_path('a')).should == content
    File.read(remote_path('a')).should == content
  end

  it 'removes file from remote if locally deleted' do
    touch local_path('a')
    touch remote_path('a')
    sync.should succeed
    rm local_path('a')

    sync.should succeed

    local_path('a').should_not exist
    remote_path('a').should_not exist
  end

  it 'removes file from local if remotely deleted' do
    touch local_path('a')
    touch remote_path('a')
    sync.should succeed
    rm remote_path('a')

    sync.should succeed

    local_path('a').should_not exist
    remote_path('a').should_not exist
  end
end
