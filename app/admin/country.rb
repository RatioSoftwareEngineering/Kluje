ActiveAdmin.register Country, as: 'CountryCode' do
  menu parent: 'Location'

  permit_params :available, :commercial, :time_zone, :default_phone_code, :currency_code,
                :top_up_amounts_raw, :sms_bundle_price, :postal_codes, :paypal, :braintree,
                :default_locale, :flag, :price_format,
                :residential_subscription_price, :commercial_subscription_price, :subscription_flag,
                budgets_attributes: [:id, :start_price, :end_price, :lead_price]

  scope :available, default: true
  scope(:unavailable) { |countries| countries.where(available: false) }

  config.sort_order = 'name_asc'

  filter :id
  filter :name
  filter :commercial

  member_action :generate_budgets, method: :post do
    country = Country.find(params[:id])

    Budget.all.each do |budget|
      CountryBudget.create country_id: country.id, budget_id: budget.id,
                           start_price: budget.start_price, end_price: budget.end_price,
                           lead_price: budget.lead_price
    end

    redirect_to resource_path(country)
  end

  action_item :generate_budgets, only: [:edit], if: proc { country_code.budgets.empty? } do
    link_to 'Generate Budgets', generate_budgets_admin_country_code_path(country_code), method: :post
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name, input_html: { disabled: true }
      f.input :time_zone
      f.input :default_locale
      f.input :default_phone_code
      f.input :currency_code
      f.input :price_format
      f.input :top_up_amounts_raw
      f.input :sms_bundle_price
      f.input :postal_codes
      f.input :paypal
      f.input :braintree
      f.input :flag, as: :attachment, hint: 'Maximum size of 3MB. JPG, GIF, PNG.', image: proc { |o| o.flag.url }
      f.input :available
      f.input :commercial
      f.input :residential_subscription_price
      f.input :commercial_subscription_price
      f.input :subscription_flag, as: :boolean
      f.inputs do
        f.has_many :budgets, heading: 'Budgets', new_record: false, class: 'tile' do |b|
          b.input :singapore_budget, label: 'Original', input_html: { disabled: true }
          b.input :start_price
          b.input :end_price
          b.input :lead_price
        end
      end
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :native_name
    column :available
    column :commercial
    column :cca2
    column :cca3
    column :flag do |country|
      image_tag country.flag.url, height: '20px'
    end
    column :time_zone
    column :default_phone_code
    column :currency_code do |country|
      country.currency_code.try(:upcase)
    end
    column :top_up_amounts do |country|
      country.top_up_amounts.map { |p| country.formatted_price(p) }.join(', ')
    end
    column :sms_bundle_price do |country|
      country.formatted_price(country.sms_bundle_price)
    end
    column :postal_codes
    column :paypal
    actions
  end

  show do
    attributes_table do
      Country.column_names.each do |column|
        row column.to_sym
      end
    end

    if country_code.commercial?
      panel 'Cities for Commercial' do
        table_for country_code.cities do
          column :name
          column :commercial
          column :actions do |city|
            view = link_to('View', admin_city_path(id: city.id))
            edit = link_to('Edit', edit_admin_city_path(id: city.id))
            "#{view} #{edit}".html_safe
          end
        end
      end
    end
    panel 'Cities for Residential' do
      table_for country_code.cities do
        column :name
        column :available
        column :actions do |city|
          view = link_to('View', admin_city_path(id: city.id))
          edit = link_to('Edit', edit_admin_city_path(id: city.id))
          "#{view} #{edit}".html_safe
        end
      end
    end

    panel 'Budgets' do
      table_for country_code.budgets do
        column :start_price do |budget|
          country_code.formatted_price(budget.start_price || 0.0)
        end
        column :end_price do |budget|
          country_code.formatted_price(budget.end_price || 0.0)
        end
        column :lead_price do |budget|
          country_code.formatted_price(budget.lead_price || 0.0)
        end
        column 'Reference currency (SGD)', &:singapore_budget
      end
    end
    active_admin_comments
  end
end
