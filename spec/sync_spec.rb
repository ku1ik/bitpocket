require 'spec_helper'

describe 'bitpocket sync' do
  include_context 'setup'

  it 'transfers new file from local to remote' do
    touch local_path('a')

    expect(sync).to succeed

    expect(local_path('a')).to exist
    expect(remote_path('a')).to exist
  end

  it 'transfers updated file from local to remote' do
    touch local_path('a')
    touch remote_path('a')
    expect(sync).to succeed

    if RUBY_PLATFORM =~ /darwin/
      system "touch -mt 200801120000 #{remote_path('a')}"
    else
      system "touch -d '00:00' #{remote_path('a')}"
    end

    cat content, local_path('a')

    expect(sync).to succeed

    expect(File.read(local_path('a')) == content).to be true
    expect(File.read(remote_path('a')) == content).to be true
  end

  it 'transfers new file from remote to local' do
    touch remote_path('a')

    expect(sync).to succeed

    expect(local_path('a')).to exist
    expect(remote_path('a')).to exist
  end

  it 'transfers updated file from remote to local' do
    touch local_path('a')
    touch remote_path('a')
    expect(sync).to succeed
    cat content, remote_path('a')

    expect(sync).to succeed

    expect(File.read(local_path('a')) == content).to be true
    expect(File.read(remote_path('a')) == content).to be true
  end

  it 'removes file from remote if locally deleted' do
    touch local_path('a')
    touch remote_path('a')
    expect(sync).to succeed
    rm local_path('a')

    expect(sync).to succeed

    expect(local_path('a')).not_to exist
    expect(remote_path('a')).not_to exist
  end

  it 'removes file from local if remotely deleted' do
    touch local_path('a')
    touch local_path('b')
    touch remote_path('a')
    expect(sync).to succeed
    rm remote_path('a')

    expect(sync).to succeed

    expect(local_path('a')).not_to exist
    expect(remote_path('a')).not_to exist
  end

  it 'handles remote deletes between syncs' do
    touch remote_path('a/c')
    touch remote_path('a/f')

    expect(sync).to succeed

    # After the sync, 'c' and 'f' are in 'added-prev', so they are excluded
    # from the next pull

    rm remote_path('a/c')
    mkdir remote_path('a/b')
    mv remote_path('a/f'), remote_path('a/b/f')

    expect(sync).to succeed

    expect(local_path('a/c')).not_to exist
    expect(local_path('a/f')).not_to exist
    expect(local_path('a/b/f')).to exist

    expect(remote_path('a/c')).not_to exist
    expect(remote_path('a/f')).not_to exist
  end

  it 'handles remote backup ' do
    # Plato Wu,2017/05/31: need handle path which contain spaces
    # Plato Wu,2017/05/31: need handle path which contain spaces
    touch local_path('a')
    touch local_path('a b/c d')
    expect(sync).to succeed
    rm local_path('a b/c d')
    expect(sync).to succeed
    expect(Dir.glob(remote_path(".bitpocket/backups/*/a b/c d")).empty?).to be false
  end

  it 'handles local backup ' do
    touch local_path('a')
    touch local_path('a b/c d')
    expect(sync).to succeed
    rm remote_path('a b/c d')
    expect(sync).to succeed
    expect(Dir.glob(local_path(".bitpocket/backups/*/a b/c d")).empty?).to be false
  end

  it 'exists with status 128 when remote path disappear ' do
    touch local_path('a')
    remove_dir @remote_dir
    # Plato Wu,2017/06/06: fisrt time is OK.
    expect(sync).to succeed
    remove_dir @remote_dir
    expect(sync).to exit_with(128)
  end

end
