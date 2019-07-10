ActiveAdmin.register LegalDocument do
  menu parent: 'Content Management'

  permit_params :title, :slug, :content, :seo_description, :seo_keywords, :language

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :content do |legal_document|
      truncate(strip_tags(legal_document.content), length: 80)
    end
    column :seo_description
    column :seo_keywords
    column :language
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :slug
      f.input :content, as: :ckeditor, input_html: { ckeditor: { height: 600 } }
      f.input :seo_description
      f.input :seo_keywords
      f.input :language
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :slug
      row :content do |document|
        document.content.html_safe
      end
      row :seo_description
      row :seo_keywords
      row :language
    end
    active_admin_comments
  end
end
