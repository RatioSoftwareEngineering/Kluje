# == Schema Information
#
# Table name: legal_documents
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  slug            :string(255)
#  content         :text(4294967295)
#  seo_description :string(255)
#  seo_keywords    :string(255)
#  language        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class LegalDocument < ActiveRecord::Base
end
