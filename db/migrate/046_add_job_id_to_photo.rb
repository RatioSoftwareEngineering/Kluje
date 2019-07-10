class AddJobIdToPhoto < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.string :job_id
    end
  end

  def self.down
    change_table :photos do |t|
      t.remove :job_id
    end
  end
end
