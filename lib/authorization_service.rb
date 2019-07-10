class AuthorizationService

  def self.check provider, token
    case provider
    when 'facebook'
      check_facebook token
    when 'google_oauth2'
      check_google token
    end
  end

  def self.check_facebook(token)
    graph = Koala::Facebook::API.new(token, Settings.facebook['secret'])
    profile = graph.get_object('me')

    { first_name: profile['first_name'],
      last_name: profile['last_name'],
      email: profile['email'],
      provider: 'facebook',
      uid: profile['id'] }
  rescue Koala::Facebook::AuthenticationError, Koala::Facebook::ClientError
    nil
  end

  def self.check_google(token)
    {}
  end
end
