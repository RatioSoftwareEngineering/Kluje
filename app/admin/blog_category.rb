ActiveAdmin.register Category, as: 'Blog Category' do
  menu parent: 'Content Management'

  permit_params :name, :slug_url

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :slug_url
    end
    f.actions
  end
end
