# == Schema Information
#
# Table name: contractors_cities
#
#  id            :integer          not null, primary key
#  contractor_id :integer
#  city_id       :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class ContractorsCity < ActiveRecord::Base
  belongs_to :contractor
  belongs_to :city
end
