require 'spec_helper'

describe 'bitpocket locking' do
  include_context 'setup'

  it "exits with status 1 when other instance is running" do
    cat $$, local_path('.bitpocket/tmp/lock/pid')

    sync.should exit_with(1)
  end

  it "exits with status 2 when stale lock found" do
    cat max_pid, local_path('.bitpocket/tmp/lock/pid')
    sync.should exit_with(2)
  end

  it "exits with status 3 when can't acquire remote lock" do
    mkdir remote_path('.bitpocket/tmp/lock')

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
  def max_pid
    if RUBY_PLATFORM =~ /darwin/
      99998
    else
      File.read('/proc/sys/kernel/pid_max').to_i
    end
  end
end
