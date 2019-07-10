class AddNumberOfQuoteToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :number_of_quote, :int
  end
end
