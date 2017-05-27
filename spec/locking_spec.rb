require 'spec_helper'

describe 'bitpocket locking' do
  include_context 'setup'

  it 'exits with status 1 when other instance is running' do
    cat $$, local_path('.bitpocket/tmp/lock/pid')

    expect(sync).to be 1
  end

  it 'exits with status 2 when stale lock found' do
    cat max_pid, local_path('.bitpocket/tmp/lock/pid')

    expect(sync).to be 2
  end

  it 'exits with status 3 when can\'t acquire remote lock' do
    mkdir remote_path('.bitpocket/tmp/lock')

    expect(sync).to be 3
  end

  it 'should release local lock after successful sync' do
    expect(succeed(sync))

    expect(not(exist(local_path('.bitpocket/tmp/lock'))))
  end

  it 'should release remote lock after successful sync' do
    expect(succeed(sync))

    expect(not(exist(remote_path('.bitpocket/tmp/lock'))))
  end

  def max_pid
    if (RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /cygwin/)
      99998
    else
      File.read('/proc/sys/kernel/pid_max').to_i
    end
  end
end
