# == Schema Information
#
# Table name: devices
#
#  id         :integer          not null, primary key
#  account_id :integer
#  token      :string(255)
#  platform   :string(255)
#  deleted_at :boolean
#  created_at :datetime
#  updated_at :datetime
#

class Device < ActiveRecord::Base
  belongs_to :account

  before_save :normalize_token

  def normalize_token
    return unless platform == 'IOS' && token.present?
    token_will_change!
    token.gsub!(/[<> ]/, '')
  end
end
