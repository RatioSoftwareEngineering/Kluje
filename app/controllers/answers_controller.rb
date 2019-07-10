class AnswersController < ApplicationController
  before_action :ensure_signed_in
  before_action :require_country_code, only: [:me]

  def create
    parent = Post.find answer_params[:parent_id]

    @answer = Answer.new answer_params.merge(
      account_id: current_account.try(:id),
      author: current_account.try(:full_name),
      meta_keyword: '',
      meta_description: answer_params[:body],
      title: "Answer for #{parent.try(:title)}"
    )
    @answer.save

    respond_to do |format|
      format.js do
        render template: 'answers/create.js.erb', layout: false
      end
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def me
    q = Question.approved

    @my_answers_count = Question.approved.where(id: current_account.answers.map(&:parent_id)).count
    @unanswered_questions_count = Question.approved.where(children_count: 0)
                                  .where.not(id: current_account.answers.map(&:parent_id))
                                  .count

    @published_answers_count = 0
    @pending_answers_count = 0
    @rejected_answers_count = 0

    if params[:answer].blank? || 'me'.eql?(params[:answer])
      my_answers = current_account.answers
      my_answers = my_answers.where(state: params[:state]) unless params[:state].blank?

      @published_answers_count = q.dup.where(id: current_account.answers.approved.map(&:parent_id)).count
      @pending_answers_count = q.dup.where(id: current_account.answers.pending.map(&:parent_id)).count
      @rejected_answers_count = q.dup.where(id: current_account.answers.rejected.map(&:parent_id)).count

      q = q.where(id: my_answers.map(&:parent_id))
    elsif 'unanswered'.eql?(params[:answer].to_s)
      q = q.where(children_count: 0)
          .where.not(id: current_account.answers.map(&:parent_id))
    end

    @q = q.search(params[:q])
    @q.sorts = 'id DESC' if @q.sorts.empty?

    page = params[:page].to_i
    page = 1 if page < 1

    @questions = @q.result.paginate(page: page, per_page: 10)
  end

  def agree
    @post = Answer.friendly.find params[:id]
    @post.voters << current_account if @post.voters.exclude? current_account

    respond_to do |format|
      format.js do
        render template: 'answers/agree.js.erb', layout: false
      end
    end
  end

  def disagree
    @post = Answer.friendly.find params[:id]
    @post.voters.delete(current_account) if @post.voters.include? current_account

    respond_to do |format|
      format.js do
        render template: 'answers/disagree.js.erb', layout: false
      end
    end
  end

  private

  def answer_params
    params.require(:answer)
      .permit(:parent_id, :body)
  end
end
