namespace :questions do
  desc 'update questions country'
  task update_questions_country: :environment do
    Question.where(country_id: nil).where.not(account_id: nil).find_each do |question|
      question.update_columns(country_id: question.account.country_id)
    end
  end

  desc 'weekly questions notify'
  task weekly_questions_notify: :environment do
    if Rails.env.development? || Rails.env.production?
      Country.all.find_each do |country|
        questions = Question.approved
                    .where(children_count: 0, country_id: country.id)
                    .order(created_at: :desc).first(10)

        next if questions.count == 0

        Account.newsletters.where(country_id: country.id).each do |account|
          # puts "Notify open questions to #{account.email}"
          QuestionMailer.weekly_questions_notify(account, questions).deliver
        end
      end
    end
  end
end
