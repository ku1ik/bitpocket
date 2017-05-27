require 'spec_helper'

describe 'bitpocket excludes' do
  include_context 'setup'

  it 'does not remove new local files' do
    touch local_path('a')

    expect(succeed(sync))

    expect(exist(local_path('a')))
  end

  it 'does not remove new local files created in parallel to previous sync' do
    expect(succeed(sync(:callback => :add_after)))
    expect(succeed(sync))

    expect(exist(local_path('after')))
  end

  it 'does not bring back removed local files that were previously created locally' do
    touch local_path('a')
    touch remote_path('a')
    expect(succeed(sync))
    rm local_path('a')

    expect(succeed(sync))

    expect(not(exist(local_path('a'))))
  end

  it 'does not bring back removed local files that came from remote in prev sync' do
    touch remote_path('a')
    expect(succeed(sync))
    expect(exist(local_path('a')))
    rm local_path('a')

    expect(succeed(sync))

    expect(not(exist(local_path('a'))))
  end

  it 'does not bring back removed local files deleted in parallel to previous sync' do
    touch local_path('after')
    expect(succeed(sync))
    expect(succeed(sync(:callback => :remove_after)))
    expect(succeed(sync))

    expect(not(exist(local_path('after'))))
  end

  it 'does not sync ignored files' do
    cat "/a\n/b", local_path('.bitpocket/exclude')
    touch local_path('a')
    touch remote_path('b')

    expect(succeed(sync))

    expect(exist(local_path('a')))
    expect(not(exist(remote_path('a'))))
    expect(not(exist(local_path('b'))))
    expect(exist(remote_path('b')))
  end

  it 'does not sync .bitpocket dir' do
    expect(succeed(sync))

    %w(config state).each do |f|
      expect(not(exist(remote_path(".bitpocket/#{f}"))))
    end
  end
end
