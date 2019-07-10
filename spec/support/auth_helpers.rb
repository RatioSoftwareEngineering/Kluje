# rubocop:disable Style/MethodName
module AuthHelpers
  def authWithUser(account)
    request.headers['access_token'] = account.api_key.access_token.to_s
  end

  def clearToken
    request.headers['access_token'] = nil
  end
end
