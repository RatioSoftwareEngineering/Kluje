object @job_category

attributes :id, :name, :skill_id, :description

node :budgets do |job_category|
  job_category.budgets.map(&:id)
end
