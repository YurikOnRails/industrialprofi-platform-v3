module Account
  class LocalesController < ApplicationController
    def update
      locale = params[:locale].to_s.strip.to_sym

      if I18n.available_locales.include?(locale)
        current_user.update(locale: locale) if user_signed_in?
        session[:locale] = locale
      end

      # Redirect back to the same page, but let the `default_url_options`
      # in `LocaleManagement` handle the `?locale=` param for the next request
      # automatically, or we force it here to be safe.
      redirect_back(fallback_location: root_path(locale: locale))
    end
  end
end
