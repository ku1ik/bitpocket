require 'spec_helper'

describe 'bitpocket locking' do
  include_context 'setup'

  it 'exits with status 1 when other instance is running' do
    cat $$, local_path('.bitpocket/tmp/lock/pid')

    expect(sync).to exit_with(1)
  end

  it 'exits with status 2 when stale lock found' do
    cat max_pid, local_path('.bitpocket/tmp/lock/pid')

    expect(sync).to exit_with(2)
  end

  it 'exits with status 3 when can\'t acquire remote lock' do
    mkdir remote_path('.bitpocket/tmp/lock')

    expect(sync).to exit_with(3)
  end

  it 'should release local lock after successful sync' do
    expect(sync).to succeed

    expect(local_path('.bitpocket/tmp/lock')).not_to exist
  end

  it 'should release remote lock after successful sync' do
    expect(sync).to succeed

    expect(remote_path('.bitpocket/tmp/lock')).not_to exist
  end

  def max_pid
    if (RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /cygwin/)
      99998
    else
      File.read('/proc/sys/kernel/pid_max').to_i
    end
  end
end
