module LocaleManagement
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  private

  def set_locale
    I18n.locale = locale_from_params ||
                  locale_from_user ||
                  locale_from_session ||
                  locale_from_headers ||
                  I18n.default_locale
  end

  def locale_from_params
    params[:locale]&.to_sym if params[:locale] && I18n.available_locales.include?(params[:locale]&.to_sym)
  end

  def locale_from_user
    current_user&.locale&.to_sym if defined?(current_user) && current_user&.locale && I18n.available_locales.include?(current_user.locale.to_sym)
  end

  def locale_from_session
    session[:locale]&.to_sym if session[:locale] && I18n.available_locales.include?(session[:locale]&.to_sym)
  end

  def locale_from_headers
    return nil unless request.env['HTTP_ACCEPT_LANGUAGE']

    header_locale = request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first&.to_sym
    header_locale if header_locale && I18n.available_locales.include?(header_locale)
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
