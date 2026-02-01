class LocalesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update]

  def update
    locale = params[:locale].to_sym

    if I18n.available_locales.include?(locale)
      session[:locale] = locale

      # Если пользователь аутентифицирован, сохраняем его выбор в базу данных
      current_user.update(locale: locale) if current_user

      redirect_back(fallback_location: root_path, notice: t('locale.changed'))
    else
      redirect_back(fallback_location: root_path, alert: t('locale.invalid'))
    end
  end
end
