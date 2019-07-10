class Commercial::HomeController < CommercialController
  skip_authorization_check

  def index
  end

  def legal
    @document = LegalDocument.find_by_language_and_slug( params[:locale] || 'en', params[:slug] )
    @document ||= LegalDocument.find_by_language_and_slug( 'en', params[:slug] )
    if @document.nil?
      flash[:error] = _('Document not found')
      redirect_to home_path
    else
      render template: 'commercial/home/legal_document'
    end
  end
end
