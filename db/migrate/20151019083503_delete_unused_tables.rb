class DeleteUnusedTables < ActiveRecord::Migration
  def change
    %w(_del_bid_discount_plans _del_deal_discounts _del_discount_jobs
       _del_extra_jobs _del_facilities_manager_jobs _del_facilities_managers
       _del_fourty_two_discounts _del_fourty_two_referals _del_job_x_payments
       _del_job_xes _del_kluje_plus_payments _del_partner_jobs _del_partners
       _del_permissions _del_property_agent_jobs _del_property_agents
       _del_referals boosted_payments plans work_locations).each do |table|
      drop_table(table) if ActiveRecord::Base.connection.table_exists?(table)
    end
  end
end
