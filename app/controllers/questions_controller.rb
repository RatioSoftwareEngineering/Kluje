class QuestionsController < ApplicationController
  skip_before_action :verify_authenticity_token, if: :js_request?
  before_action :ensure_signed_in, only: [:me]
  before_action :require_country_code, only: [:index, :show, :me, :filter, :new]

  def index
    q = Question.includes(:category).approved.where(country_id: params[:country_id] || current_country.id)

    q = filter(q)

    @q = q.search(params[:q])
    @q.sorts = 'id DESC' if @q.sorts.empty?

    page = params[:page].to_i
    page = 1 if page < 1

    @questions = @q.result.paginate(page: page, per_page: 10)

    respond_to do |format|
      format.html
      format.js do
        render json: { access: false }, layout: false
      end
    end
  end

  def filter(query) # rubocop:disable Metrics/CyclomaticComplexity
    query = query.where(children_count: 0) if 'unanswered'.eql?(params[:answer])
    query = query.where('children_count > 0') if 'answered'.eql?(params[:answer])
    query = query.where(category_id: params[:category].map(&:to_i)) unless params[:category].blank?
    query = query.where(state: params[:state]) unless params[:state].blank?
    query = query.order(updated_at: :DESC) if 'recent'.eql?(params[:filter])
    query = query.order('COALESCE(SUM(punches.hits),0) DESC') if 'popular'.eql?(params[:filter])
    query
  end

  def me
    q = current_account.questions

    @all_questions_count = q.dup.count
    @answered_questions_count = q.dup.where('children_count > 0').count
    @unanswered_questions_count = q.dup.where(children_count: 0).count

    q = filter(q)

    @published_questions_count = q.dup.approved.count
    @pending_questions_count = q.dup.pending.count
    @rejected_questions_count = q.dup.rejected.count

    @q = q.search(params[:q])
    @q.sorts = 'id DESC' if @q.sorts.empty?

    page = params[:page].to_i
    page = 1 if page < 1

    @questions = @q.result.paginate(page: page, per_page: 10)
  end

  def new
    redirect_to questions_path(locale: current_locale_country)
  end

  def show
    country = locale_country
    @question = Question.where(slug_url: params[:id], country_id: country.id)
                .where("state = 'approved' OR account_id = ?", current_account.try(:id)).first

    # return redirect_to not_found_path if @question.nil?
    need_to_redirect = session.delete(:redirect_to_target)
    if @question.nil?
      if need_to_redirect
        return redirect_to questions_path(locale: current_locale_country)
      else
        return error404
      end
    end
    
    @question.punch(request)

    @recent_questions = Question.approved.where(country_id: country.id).where.not(id: @question.id).first(5)

    @blogs = []
    if @question.category
      @blogs = Blog.published.latest.category(@question.category)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    account = signed_in? ? current_account : Account.where(email: question_params[:email]).first

    if account.nil?
      password = Devise.friendly_token.first(8)
      account = Account.new(
        first_name: question_params[:first_name],
        last_name: question_params[:last_name],
        email: question_params[:email],
        country_id: question_params[:country_id],
        password: password
      )

      account.skip_confirmation_notification!
    end

    author = account.try(:full_name).strip
    author = account.try(:email) if author.blank?

    @question = Question.new(
      question_params.merge(
        author: author,
        meta_keyword: question_params[:title],
        meta_description: question_params[:body]
      ).except(:first_name, :last_name, :email, :country_id)
    )

    if @question.valid? && @question.save
      # generate account
      if account.new_record?
        account.save
        QuestionMailer.account_generated(account, password).deliver_now
      end
      @question.update(account_id: account.id, country_id: account.try(:country_id) || current_country.try(:id))
      @question.deliver
      @notice = _('Your question has been sent, someone will contact you shortly.')
    else
      @error =  @question.errors.full_messages.first
    end

    respond_to do |format|
      format.js do
        render template: 'questions/create.js.erb', layout: false
      end
    end
  end

  private

  def question_params
    params.require(:ask_expert)
      .permit(:first_name, :last_name, :email, :country_id, :category_id, :title, :body, :anonymous, :agree_terms)
  end

  def js_request?
    request.format.js?
  end
end
