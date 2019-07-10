FastGettext.add_text_domain('kluje', path: Rails.root.join('config', 'locales'))
FastGettext.default_available_locales = ['en', 'th', 'zh_CN', 'zh_HK']
FastGettext.default_text_domain = 'kluje'

module I18n
  class Config
    def locale
      FastGettext.locale.to_sym
    end
  end
end
