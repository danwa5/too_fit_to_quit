class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def fitbit_oauth2
    authenticate('Fitbit')
  end

  def strava
    authenticate('Strava')
  end

  private

  def authenticate(provider)
    @user = User.from_omniauth(request.env['omniauth.auth'], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => provider) if is_navigational_format?
    else
      session["devise.#{provider.downcase}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end

end
