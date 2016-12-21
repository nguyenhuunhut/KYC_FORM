class Users::SessionsController < Devise::SessionsController
  respond_to :json
  #
  # before_filter :check_user_confirmation, only: :create

  def create
    session['user_auth'] = params[:user]

    resource = User.find_by_email params[:user][:email]


    if resource && resource.valid_password?(params[:user][:password])
      if resource.confirmed?
        sign_in(resource_name, resource)
        message = I18n.t 'devise.sessions.signed_in'

        yield resource if block_given?

        return render :json => {:success => true, :login => true, :data =>  {:message => message}}
      else

        message = I18n.t 'devise.failure.unconfirmed'
        return render :json => {:success => false, :login => false,:message => message }
      end
    else
      resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    end

  end

  def failure
    user = User.where(email: session['user_auth'][:email]).first rescue nil
    message = I18n.t 'devise.failure.invalid', authentication_keys: "email"

    render :json => {:success => false, :data => {:message => message, :cause => 'invalid'} }
  end

  def check_user_confirmation
      user = User.find_by_email params[:user][:email]
      byebug
    message = I18n.t 'devise.failure.unconfirmed'
    return render :json => {:success => false, :login => false,:message => message }
  end
end
