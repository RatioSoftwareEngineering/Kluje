object @account

attributes :id, :first_name, :last_name, :email, :role, :locale, :mobile_number,
           :deleted_at, :created_at, :updated_at,
           :suspended_at, :is_email_verified, :no_of_account, :uid, :provider, :country_id

child :api_key do
  attributes :access_token
end
