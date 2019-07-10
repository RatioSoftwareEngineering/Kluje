Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
    Settings['facebook']['id'],
    Settings['facebook']['secret'],
    scope: 'email',
    client_options: { site: 'https://graph.facebook.com/v2.0',
                     authorize_url: 'https://www.facebook.com/v2.0/dialog/oauth' }

  provider :google_oauth2,
    Settings['google']['id'],
    Settings['google']['secret'],
    { access_type: 'online',
     approval_prompt: '' }
end

module OmniauthInitializer
  def self.registered(app)
    app.use OmniAuth::Builder do
    end
  end
end
