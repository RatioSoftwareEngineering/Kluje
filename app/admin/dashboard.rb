ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: "Kluje Dashboard" do
    columns do
      column do
        panel "Country Stats" do
          countries = Country.includes(:jobs).available
          countries = [current_account.country] if current_account.country_admin?
          countries = countries.to_a
          countries.sort_by!{|c| -c.jobs.count}
          stats = []
          stats << ['Total', '-', Account.contractor.count, Account.homeowner.count, Job.count, '-']
          countries.each do |country|
            stats << [country.name, '-',
                      country.accounts.contractor.distinct.count,
                      country.accounts.homeowner.distinct.count,
                      country.jobs.distinct.count,
                      country.formatted_price(Paypal::TopUp.processed.where(currency: country.currency_code).pluck(:amount).sum)
                     ]
            if country.cities.count > 1
              country.cities.includes(:contractors, :homeowners).available.each do |city|
                stats << [city.country.name,
                          city.name,
                          city.contractors.distinct.count,
                          city.homeowners.distinct.count,
                          city.jobs.distinct.count,
                          '-']
              end
            end
          end
          stats.each do |line|
            line.map!{|f| "<b>#{f}</b>".html_safe} if line[1] == '-'
          end
          table do
            thead do
              %w[Country City Contractors Homeowners Jobs TopUps].each &method(:th)
            end
            tbody do
              stats.each do |country|
                tr do
                  country.each &method(:td)
                end
              end
            end
          end
        end
      end
    end
  end
end
