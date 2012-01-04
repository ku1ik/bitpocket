require 'spec_helper'

describe 'bitpocket excludes' do
  include_context 'setup'

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

    %w(config state).each do |f|
      remote_path(".bitpocket/#{f}").should_not exist
    end
  end
end
