require 'spec_helper'

describe 'bitpocket sync' do
  include_context 'setup'

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
    if RUBY_PLATFORM =~ /darwin/
      system "touch -mt 200801120000 #{remote_path('a')}"
    else
      system "touch -d '00:00' #{remote_path('a')}"
    end
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
