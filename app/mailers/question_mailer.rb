class QuestionMailer < ActionMailer::Base
  include Resque::Mailer
  layout 'mailer'

  def ask_expert(question)
    locals = {
      name: question.account.try(:full_name) || question.author,
      email: question.account.try(:email),
      question: question.body,
      user_info: question.account.try(:id) || 'anonymous'
    }

    subject = ''
    subject += "[#{Rails.env}] " unless Rails.env.production?
    subject += 'New Ask an Expert Question!'

    mail(to: 'andrew.ew@kluje.com', layout: 'mailer', subject: subject) do |format|
      format.html do
        render 'ask_an_expert', locals: locals
      end
    end
  end

  def account_generated(account, password)
    return unless account.email

    mail(to: account.email, subject: 'Your account has been generated on Kluje') do |format|
      format.html do
        render 'account_generated', locals: { account: account, password: password }
      end
    end
  end

  def client_question_published(account, question)
    return unless account.email

    mail(to: account.email, subject: 'Your question have beed approved on Kluje') do |format|
      format.html do
        render 'client_question_published', locals: { account: account, question: question }
      end
    end
  end

  def contractor_question_published(account, question)
    return unless account.email

    mail(to: account.email, subject: 'Have new question on Kluje') do |format|
      format.html do
        render 'contractor_question_published', locals: { account: account, question: question }
      end
    end
  end

  def client_answer_published(account, question)
    return unless account.email

    mail(to: account.email, subject: 'Your question have beed answered on Kluje') do |format|
      format.html do
        render 'client_answer_published', locals: { account: account, question: question }
      end
    end
  end

  def contractor_answer_published(account, question)
    return unless account.email

    mail(to: account.email, subject: 'Your answer have beed approved on Kluje') do |format|
      format.html do
        render 'contractor_answer_published', locals: { account: account, question: question }
      end
    end
  end

  def weekly_questions_notify(account, questions)
    return unless account.email

    mail(to: account.email, subject: 'New questions on Kluje') do |format|
      format.html do
        render 'weekly_questions_notify', locals: { account: account, questions: questions }
      end
    end
  end
end
