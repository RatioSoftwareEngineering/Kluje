require 'rails_helper'

RSpec.describe LandingPagesController, type: :routing do
  describe 'Show' do
    it 'routes to Singapore(default) show as html format' do
      expect(get: '/en/trade/window-contractor').to route_to(action: 'show', controller: 'landing_pages', locale: 'en', slug: 'window-contractor')
    end

    it 'routes to show as html format' do
      expect(get: '/en-my/trade/window-contractor').to route_to(action: 'show', controller: 'landing_pages', locale: 'en-my', slug: 'window-contractor')
    end
  end
end
