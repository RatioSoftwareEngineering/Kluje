class RemoveUnusedTables < ActiveRecord::Migration
  TABLES = [:bid_histories, :contractor_countries, :deal_discounts,
            :discount_jobs, :extra_jobs, :facilities_manager_jobs,
            :facilities_managers, :fourty_two_discounts, :fourty_two_referals,
            :job_x_payments, :job_xes, :kluje_plus_payments, :partner_jobs,
            :partners, :permissions, :property_agent_jobs, :property_agents,
            :referals].freeze

  def self.up
    TABLES.each do |table|
      rename_table table, "_del_#{table}" if ActiveRecord::Base.connection.table_exists? table
    end
  end

  def self.down
    TABLES.each do |table|
      rename_table "_del_#{table}", table if ActiveRecord::Base.connection.table_exists? "_del_#{table}"
    end
  end
end
