ActiveAdmin.register Skill, as: 'ContractorSkills' do

  actions :all
  permit_params :name, :description

  index do
    selectable_column
    id_column
    column :name
    column :description
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :description
    end
    f.actions
  end
end
