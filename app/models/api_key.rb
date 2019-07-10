# == Schema Information
#
# Table name: api_keys
#
#  id           :integer          not null, primary key
#  access_token :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  account_id   :integer
#

class ApiKey < ActiveRecord::Base
  belongs_to :account
  before_create :generate_access_token

  attr_accessible :access_token, :account_id

  private

  def generate_access_token
    # begin
    self.access_token = SecureRandom.hex
    # end while self.class.exists?(access_token: access_token)
  end
end
