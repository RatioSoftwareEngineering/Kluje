ActiveAdmin.register_page 'Charts' do
  content title: 'Kluje Dashboard' do
    render partial: 'js'
    panel 'Jobs' do
      columns do
        column do
          tabs do
            tab 'Day' do
              div id: 'day_jobs_chart'
            end
            tab 'Week' do
              div id: 'week_jobs_chart'
            end
            tab 'Month' do
              div id: 'month_jobs_chart'
            end
            render partial: 'residential_jobs'
          end
        end
        column do
          tabs do
            tab 'Day' do
              div id: 'day_jobs_chart2'
            end
            tab 'Week' do
              div id: 'week_jobs_chart2'
            end
            tab 'Month' do
              div id: 'month_jobs_chart2'
            end
            render partial: 'commercial_jobs'
          end
        end
      end
    end

    panel 'Contractor Sign Ups' do
      columns do
        column do
          tabs do
            tab 'Day' do
              div id: 'day_contractors_chart'
            end
            tab 'Week' do
              div id: 'week_contractors_chart'
            end
            tab 'Month' do
              div id: 'month_contractors_chart'
            end
            render partial: 'contractors'
          end
        end
        column do
          tabs do
            tab 'Day' do
              div id: 'day_contractors_chart2'
            end
            tab 'Week' do
              div id: 'week_contractors_chart2'
            end
            tab 'Month' do
              div id: 'month_contractors_chart2'
            end
          end
          render partial: 'commercial_contractors'
        end
      end
    end

    panel 'Credit' do
      tabs do
        Country.available.each do |country|
          currency = country.currency_code.upcase
          tab country.name do
            columns do
              column do
                div id: "#{currency}_top_ups_history"
                render partial: 'top_up_history', locals: { country: country }
              end
              column do
                div id: "#{currency}_bids_history"
                render partial: 'bids_history', locals: { country: country }
              end
            end
            div id: "#{currency}_credit_chart"
            render partial: 'credit', locals: { country: country }
          end
        end
      end
    end

    panel 'Revenue' do
      tabs do
        Country.available.each do |country|
          currency = country.currency_code.upcase
          Revenue.refresh(country)
          tab country.name do
            div id: "#{currency}_revenue"
            render partial: 'revenue', locals: { country: country }
          end
        end
      end
    end

    panel 'Number of Bids' do
      tabs do
        tab 'Day' do
          div id: 'day_bids_chart'
        end
        tab 'Week' do
          div id: 'week_bids_chart'
        end
        tab 'Month' do
          div id: 'month_bids_chart'
        end
      end
      render partial: 'bids'
    end
  end
end
