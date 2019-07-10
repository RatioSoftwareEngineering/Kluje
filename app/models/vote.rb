# == Schema Information
#
# Table name: votes
#
#  id         :integer          not null, primary key
#  account_id :integer
#  post_id    :integer
#
# Indexes
#
#  index_votes_on_account_id  (account_id)
#  index_votes_on_post_id     (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (post_id => posts.id)
#

class Vote < ActiveRecord::Base
  belongs_to :account
  belongs_to :post
end
