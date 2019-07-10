# == Schema Information
#
# Table name: posts
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  body                   :text(65535)
#  meta_keyword           :text(65535)
#  meta_description       :text(65535)
#  category_id            :integer
#  image                  :string(255)
#  author                 :string(255)
#  author_google_plus_url :string(255)
#  is_published           :boolean
#  published_at           :datetime
#  deleted_at             :datetime
#  slug_url               :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  post_type              :string(255)
#  parent_id              :integer
#  account_id             :integer
#  anonymous              :boolean
#  children_count         :integer          default(0), not null
#  state                  :string(255)      default("pending"), not null
#  votes_count            :integer          default(0)
#  country_id             :integer
#  visible_all_countries  :boolean          default(TRUE)
#
# Indexes
#
#  index_posts_on_account_id  (account_id)
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#

class RejectPost < Post
  default_scope { where(post_type: :reject) }
end
