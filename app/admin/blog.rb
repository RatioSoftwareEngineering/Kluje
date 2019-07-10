ActiveAdmin.register Blog do
  menu parent: 'Content Management'

  permit_params :title, :body, :meta_keyword, :meta_description, :category_id,
                :image, :author, :author_google_plus_url, :is_published, :published_at,
                :slug_url, :visible_all_countries, category_ids: [], country_ids: []

  scope(:published)
  scope(:unpublished)

  index do
    selectable_column
    id_column
    column :title
    column :slug_url
    column :author
    column :categories do |post|
      post.categories.each do |category|
        div category.name
      end
    end

    column :body do |post|
      truncate(strip_tags(post.body), length: 80)
    end

    column :visible_all_countries do |post|
      status_tag(post.visible_all_countries? ? 'yes' : 'no')
    end


    column :published do |post|
      status_tag(post.published? ? 'yes' : 'no')
    end
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :title
          row :slug_url
          row :meta_keyword
          row :meta_description
          row :categories do |post|
            post.categories.each do |category|
              div category.name
            end
          end

          row :image do |post|
            image_tag post.image, style: 'height: 200px'
          end
          row :author
          row :author_google_plus_url
          row :is_published
          row :published_at
          row :deleted_at
          row :created_at
          row :updated_at

          row :visible_all_countries
          row :countries do |post|
           post.countries.map do |country|
             link_to country.name, admin_country_code_path(id: country.id)
           end.join(', ').html_safe
          end unless blog.visible_all_countries
        end
        active_admin_comments
      end
      column do
        div :class => 'post-content' do
          attributes_table do
            row :body do |post|
              post.body.html_safe
            end
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :title
      f.input :slug_url
      f.input :meta_keyword, as: :string
      f.input :meta_description, as: :string
      f.input :body, as: :ckeditor, input_html: { ckeditor: { height: 600 } }
      f.input :categories
      f.input :image, as: :attachment, image: proc { |o| o.image.url }
      f.input :author
      f.input :author_google_plus_url
      f.input :visible_all_countries
      f.input :countries, as: :check_boxes, collection: Country.available.all
      f.input :is_published
      f.input :published_at
    end
    f.actions

    render partial: 'blog', locals: {  }

  end

  controller do
    def scoped_collection
      super.includes(:categories)
    end

    def find_resource
      Blog.new
      Blog.friendly.find params[:id] if params[:id].present?
    end
  end
end
