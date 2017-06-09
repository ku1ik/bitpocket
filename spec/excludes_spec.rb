require 'spec_helper'

describe 'bitpocket excludes' do
  include_context 'setup'

  it 'does not remove new local files' do
    touch local_path('a')

    expect(sync).to succeed

    expect(local_path('a')).to exist
  end

  it 'does not remove new local files created in parallel to previous sync' do
    expect(succeed(sync(:callback => :add_after)))
    expect(sync).to succeed

    expect(exist(local_path('after')))
  end

  it 'does not bring back removed local files that were previously created locally' do
    touch local_path('a')
    touch remote_path('a')
    expect(sync).to succeed
    rm local_path('a')

    expect(sync).to succeed

    expect(local_path('a')).not_to exist
  end

  it 'does not bring back removed local files that came from remote in prev sync' do
    touch remote_path('a')
    expect(sync).to succeed
    expect(local_path('a')).to exist
    rm local_path('a')

    expect(sync).to succeed

    expect(local_path('a')).not_to exist
  end

  it 'does not bring back removed local files deleted in parallel to previous sync' do
    touch local_path('a')
    touch local_path('after')
    expect(sync).to succeed
    expect(succeed(sync(:callback => :remove_after)))
    expect(sync).to succeed

    expect(local_path('after')).not_to exist
  end

  it 'does not sync ignored files' do
    cat "/a\n/b", local_path('.bitpocket/exclude')
    touch local_path('a')
    touch remote_path('b')

    expect(sync).to succeed

    expect(local_path('a')).to exist
    expect(remote_path('a')).not_to exist
    expect(local_path('b')).not_to exist
    expect(remote_path('b')).to exist
  end

  it 'does not sync .bitpocket dir' do
    expect(sync).to succeed

    %w(config state).each do |f|
      expect(remote_path(".bitpocket/#{f}")).not_to exist
    end
  end
end
