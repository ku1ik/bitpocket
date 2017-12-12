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

  it 'handles remote deletes between syncs' do
    touch remote_path('a/c')
    touch remote_path('a/f')

    sync.should succeed

    # After the sync, 'c' and 'f' are in 'added-prev', so they are excluded
    # from the next pull

    rm remote_path('a/c')
    mkdir remote_path('a/b')
    mv remote_path('a/f'), remote_path('a/b/f')

    sync.should succeed

    local_path('a/c').should_not exist
    local_path('a/f').should_not exist
    local_path('a/b/f').should exist

    remote_path('a/c').should_not exist
    remote_path('a/f').should_not exist
  end

  it 'does not remove new local files which contain []`*?' do
    touch remote_path('a*')
    touch remote_path('b?')

    sync.should succeed

    local_path('a*').should exist
    remote_path('a*').should exist
    local_path('b?').should exist
    remote_path('b?').should exist

    touch local_path('[]')
    touch local_path('`hello')

    sync.should succeed

    local_path('[]').should exist
    remote_path('[]').should exist
    local_path('`hello').should exist
    remote_path('`hello').should exist

    rm local_path('[]')
    rm local_path('`hello')
    rm remote_path('a*')
    rm remote_path('b?')

    sync.should succeed

    local_path('a*').should_not exist
    remote_path('a*').should_not exist
    local_path('b?').should_not exist
    remote_path('b?').should_not exist
    local_path('[]').should_not exist
    remote_path('[]').should_not exist
    local_path('`hello').should_not exist
    remote_path('`hello').should_not exist
  end

  it 'does not revert modify time of local folders with new files' do
    touch local_path('a/a')
    touch remote_path('a/a')
    sync.should succeed

    touch local_path('a/b')
    if RUBY_PLATFORM =~ /darwin/
      system "touch -mt 200801120000 #{local_path('a/')}"
    else
      system "touch -t '200801120000' #{local_path('a/')}"
    end
    sync.should succeed

    File.mtime(local_path('a/')).should == Time.new(2008,1,12,0,0)
  end

  it 'does not remove soft link when -L is not set' do
    cat content, local_path('b')
    ln 'b', local_path('a')

    sync.should succeed

    remote_path('a').should exist
    remote_path('b').should exist

    File.read(remote_path('a')).should == content

    rm local_path('a')
    cat content + content, local_path('a')

    sync.should succeed

    File.read(remote_path('a')).should == content + content
  end
end
