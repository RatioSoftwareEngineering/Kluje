class BlogsController < ApplicationController
  before_action :categories
  before_action :check_allow_country, only: [:post]
  # before_action :require_country_code, only: [:show]

  def show
    @category = params[:category] && Category.find_by(slug_url: params[:category])

    # @posts = Blog.published.latest
    @posts = current_country.blogs.published.latest

    # @posts = @category.posts.published.latest if @category
    @posts = @posts.category(@category) if @category

    @posts = @posts.tag(params[:tag]) if params[:tag]

    respond_to do |format|
      format.rss do
        render 'blog/index', layout: false
      end
      format.html do
        page = params[:page].to_i
        page = 1 if page < 1
        @posts = @posts.paginate(page: page, per_page: 8)
        render 'blog/index'
      end
    end
  end

  def post
    if @post && (@post.published? || current_account.try(:admin?))
      @base_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/en/post/#{@post.slug_url}"
      @related_posts = []
      categories = @post.categories.pluck(:id)
      unless categories.empty?
        @related_posts = current_country.blogs.published.latest
                         .joins(:categories)
                         .where('categories.id in (?) and posts.id != ?', categories, @post.id)[0..1]
      end
      render 'blog/post'
    else
      flash[:notice] = _('Post not found')
      redirect_to blog_path()
    end
  end

  private

  def categories
    @categories = Category.all
  end

  def check_allow_country
    country = locale_country
    if contain_country_code?
      @post = country.blogs.find_by_slug_url(params[:post]) if country
    else
      @post = Blog.find_by_slug_url(params[:post])
    end

    if session.delete(:redirect_to_target)
      if @post.blank?
        redirect_to blog_path()
      elsif @post.visible_all_countries? && contain_country_code?
        redirect_to @post.blog_url(current_locale, current_locale_country)
      end
    else
      if @post.blank? || (@post.visible_all_countries? && contain_country_code?) || (!@post.visible_all_countries? && !contain_country_code?)
        error404
      end
    end
  end
end
