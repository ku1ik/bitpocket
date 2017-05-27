require 'spec_helper'

describe 'bitpocket sync' do
  include_context 'setup'

  it 'transfers new file from local to remote' do
    touch local_path('a')

    expect(succeed(sync))

    expect(exist(local_path('a')))
    expect(exist(remote_path('a')))
  end

  it 'transfers updated file from local to remote' do
    touch local_path('a')
    touch remote_path('a')
    expect(succeed(sync))

    if RUBY_PLATFORM =~ /darwin/
      system "touch -mt 200801120000 #{remote_path('a')}"
    else
      system "touch -d '00:00' #{remote_path('a')}"
    end

    cat content, local_path('a')

    expect(succeed(sync))

    expect(File.read(local_path('a')) == content)
    expect(File.read(remote_path('a')) == content)
  end

  it 'transfers new file from remote to local' do
    touch remote_path('a')

    expect(succeed(sync))

    expect(exist(local_path('a')))
    expect(exist(remote_path('a')))
  end

  it 'transfers updated file from remote to local' do
    touch local_path('a')
    touch remote_path('a')
    expect(succeed(sync))
    cat content, remote_path('a')

    expect(succeed(sync))

    expect(File.read(local_path('a')) == content)
    expect(File.read(remote_path('a')) == content)
  end

  it 'removes file from remote if locally deleted' do
    touch local_path('a')
    touch remote_path('a')
    expect(succeed(sync))
    rm local_path('a')

    expect(succeed(sync))

    expect(not(exist(local_path('a'))))
    expect(not(exist(remote_path('a'))))
  end

  it 'removes file from local if remotely deleted' do
    touch local_path('a')
    touch remote_path('a')
    expect(succeed(sync))
    rm remote_path('a')

    expect(succeed(sync))

    expect(not(exist(local_path('a'))))
    expect(not(exist(remote_path('a'))))
  end

  it 'handles remote deletes between syncs' do
    touch remote_path('a/c')
    touch remote_path('a/f')

    expect(succeed(sync))

    # After the sync, 'c' and 'f' are in 'added-prev', so they are excluded
    # from the next pull

    rm remote_path('a/c')
    mkdir remote_path('a/b')
    mv remote_path('a/f'), remote_path('a/b/f')

    expect(succeed(sync))

    expect(not(exist(local_path('a/c'))))
    expect(not(exist(local_path('a/f'))))
    expect(exist(local_path('a/b/f')))

    expect(not(exist(remote_path('a/c'))))
    expect(not(exist(remote_path('a/f'))))
  end
end
