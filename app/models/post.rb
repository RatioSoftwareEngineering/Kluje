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

class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged, slug_column: :slug_url

  def slug_candidates
    [
      :title,
      [:title, :author]
    ]
  end

  acts_as_paranoid
  acts_as_punchable

  has_many :post_categories
  has_many :categories, through: :post_categories

  belongs_to :account
  belongs_to :country
  belongs_to :parent, class_name: 'Post', foreign_key: :parent_id
  has_many :childs, class_name: 'Post', foreign_key: :parent_id

  has_many :votes
  has_many :voters, through: :votes, source: :account

  has_and_belongs_to_many :countries

  mount_uploader :image, ImageUploader

  # Remove validate require author_google_plus_url
  validates :author, presence: true
  validates :title, presence: true
  validates :body, presence: true
  validates :meta_keyword, :meta_description, presence: true, if: -> { post_type == 'Post' }

  # validates :image, presence: true

  scope :latest, -> { order('published_at DESC') }
  scope :published, -> { where(is_published: true).where('published_at IS NOT NULL') }
  scope :unpublished, -> { where(is_published: false) }
  scope :tag, ->(tag) { where('meta_keyword LIKE ?', "%#{tag.underscore.humanize}%") }
  scope :category, ->(category) { joins(:post_categories).where( post_categories: {category: category}) }

  scope :blog, -> { where(post_type: :blog) }
  scope :question, -> { where(post_type: :question) }
  scope :answer, -> { where(post_type: :answer) }
  scope :reject_post, -> { where(post_type: :reject) }

  scope :pending, -> { where(state: :pending) }
  scope :approved, -> { where(state: :approved) }
  scope :rejected, -> { where(state: :rejected) }

  attr_accessor :reject_reason

  before_save do
    self.slug_url = slug_url.parameterize
  end

  def published?
    is_published
  end

  def author_name
    return 'Anonymous' if anonymous
    author
  end

  state_machine initial: :pending do
    event :approve do
      transition pending: :approved
    end

    event :reject do
      transition [:approved, :pending] => :rejected
    end

    after_transition pending: :approved do |post|
      post.update(is_published: true, updated_at: Time.zone.now)
      if post.parent.present?
        parent = post.parent
        parent.update(children_count: parent.childs.approved.count)
      end

      if 'question'.eql?(post.post_type)
        # notify to client
        QuestionMailer.client_question_published(post.account, post).deliver_now

        # notify to contractor
        Account.newsletters.where(country_id: post.country_id).find_each do |account|
          QuestionMailer.contractor_question_published(account, post).deliver
        end
      elsif 'answer'.eql?(post.post_type) && post.parent.present? && 'question'.eql?(post.parent.post_type)
        # notify to client
        QuestionMailer.client_answer_published(post.parent.account, post.parent).deliver_now if post.parent.present?

        # notify to contractor
        QuestionMailer.contractor_answer_published(post.account, post.parent).deliver_now
      end
    end

    after_transition any => :rejected do |post|
      post.update(is_published: false)
      if post.parent.present?
        parent = post.parent
        parent.update(children_count: parent.childs.approved.count)
      end
    end
  end

  def state_name
    case state
    when 'approved'
      'Published'
    when 'pending'
      'Waiting for Approve'
    when 'rejected'
      'Rejected'
    end
  end

  def author_avatar
    return account.contractor.company_logo.url if account.present? && \
                                                  account.contractor.present? && \
                                                  account.contractor.company_logo.present?
  end
end
