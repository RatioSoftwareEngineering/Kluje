class Ability
  include CanCan::Ability

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def initialize(account)
    account ||= Account.new

    # All
    can :update, Account, id: account.id
    can :create, ApiKey, account_id: account.id

    # Admin
    if account.admin?
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can :read, ActiveAdmin::Page, name: 'Charts'

      if account.admin? && !account.analytics?
        can :access, :ckeditor # needed to access Ckeditor filebrowser
        can [:read, :create, :destroy], Ckeditor::Picture
        can [:read, :create, :destroy], Ckeditor::AttachmentFile

        can [:create, :read, :update], LandingPage
        can :create, City
        can [:read, :create], ActiveAdmin::Comment
        can [:approve, :update], Rating
        can [:create, :read, :update, :destroy], Skill
        can [:create, :read, :update, :destroy], Fee
        can [:create, :read, :destroy], WaitingList
        can [:read, :update, :destroy], Job
        can [:read, :update, :destroy], Bid
        can [:read, :update, :destroy], Invoice
        can [:update, :approve, :reject, :do_reject], Question
        can [:update, :approve, :reject, :do_reject], Answer

        if account.country_admin?
          can [:update, :read, :suspend, :destroy], Account, country_id: account.country_id
          can [:read, :update, :destroy], City, country_id: account.country_id
          can :read, Country, id: account.country_id
          can :update, Country, id: account.country_id
          can [:update, :destroy], ActiveAdmin::Comment, author_id: account.id
          can [:read, :update, :archive], Job, city: { country_id: account.country_id }
          can [:create, :read], LegalDocument
          can :update, LegalDocument do |document|
            document.language.nil? || document.language == account.country.default_locale
          end
        elsif account.global_admin?
          can :read, :all
          can [:update, :suspend, :destroy], Account
          can [:create, :update, :destroy], Category
          can [:update, :destroy], City
          can [:update, :destroy], ActiveAdmin::Comment
          can :update, Country
          can [:read, :update, :archive], Job
          can [:create, :update], LegalDocument
          can [:create, :update, :destroy], Post
        end
      end
    # Contractor
    elsif account.contractor?
      contractor = account.contractor
      can [:create, :update], Bid, contractor_id: contractor.id
      can [:create, :update], Clarification, contractor_id: contractor.id
    # Homeowner
    elsif account.homeowner?
      can [:update], Bid
      can [:update], Clarification
    end
  end
end
