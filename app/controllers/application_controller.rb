require 'http_accept_language'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  add_flash_types :error, :alert

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_locale

  # This is necessary for correct devise routing with locales: https://github.com/plataformatec/devise/wiki/How-To:--Redirect-with-locale-after-authentication-failure
  def self.default_url_options
    merge_locale_to_options(super())
  end

  # This happens after the *_url *_path helpers
  def default_url_options(options = {})
    self.class.merge_locale_to_options(options)
  end

  protected

  def self.merge_locale_to_options(options)
    { locale: I18n.locale }.merge options
  end

  # :nocov:
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  def set_locale
    unless params[:locale].nil?
      I18n.locale = params[:locale]
    else
      compatible_locale = http_accept_language.compatible_language_from(I18n.available_locales)
      unless compatible_locale.nil?
        I18n.locale = compatible_locale
      end
    end
  end

end
