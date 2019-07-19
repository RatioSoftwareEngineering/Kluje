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

class Blog < Post

  default_scope { where(post_type: :blog) }
  scope :for_all_country, -> { where(visible_all_countries: true) }

  validates :title, uniqueness: { case_sensitive: false, message: '%{value} already exit.' }
  validates :slug_url, uniqueness: { case_sensitive: false, message: '%{value} already exit.' }

  def blog_url current_locale, current_locale_country
    visible_all_countries? ? Rails.application.routes.url_helpers.post_blog_path(locale: current_locale, post: slug_url) : Rails.application.routes.url_helpers.post_blog_path(locale: current_locale_country, post: slug_url)
  end
end
