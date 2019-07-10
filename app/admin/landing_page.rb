ActiveAdmin.register LandingPage do
  menu parent: 'Content Management'

  # permit_params :country_ids, :title, :skill_id, :landing_page_category_id,
  #   :slug, :header, :content, :banner, :description, :keywords, :language,
  #   :published_at

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :header
    column :content do |page|
      truncate(strip_tags(page.content), length: 80)
    end
    column :banner do |page|
      image_tag page.banner.url, width: '200px'
    end
    column :description do |page|
      truncate(page.description, length: 80)
    end
    column :keywords do |page|
      truncate(page.keywords, length: 80)
    end
    column :language do |page|
      status_tag(page.language)
    end
    column :visible_all_countries do |page|
      status_tag(page.visible_all_countries? ? 'yes' : 'no')
    end
    column :published do |page|
      status_tag(page.published? ? 'yes' : 'no')
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :skill
      row :landing_page_category
      row :slug
      row :header
      row :content do |page|
        page.content.html_safe
      end
      row :banner do |page|
        image_tag page.banner, width: '300px'
      end
      row :description
      row :keywords
      row :language
      row :visible_all_countries
      row :countries do |page|
        page.countries.map do |country|
          link_to country.name, admin_country_code_path(id: country.id)
        end.join(', ').html_safe
      end unless landing_page.visible_all_countries
        
      row :updated_at
      row :published_at
      row :created_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.id
    f.inputs do
      f.input :title
      f.input :skill
      f.input :landing_page_category
      f.input :slug
      f.input :header
      f.input :content, as: :ckeditor, input_html: { ckeditor: { height: 600 } }
      f.input :banner
      f.input :description
      f.input :keywords
      f.input :language
      f.input :visible_all_countries
      f.input :countries, as: :check_boxes, collection: Country.available.all
      f.input :published_at
    end
    f.actions

    render partial: 'landing_page', locals: {  }
  end
end
