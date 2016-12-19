class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        message = find_message(:signed_up)
        sign_up(resource_name, resource)
        # UserNotifier.send_signup_email(resource).deliver
        UserMailer.registration_confirmation(resource).deliver
        return render :json => {:success => true, :data =>  {:message => message}}
      else
        message = find_message(:"signed_up_but_#{resource.inactive_message}" )
        expire_data_after_sign_in!
        return render :json => {:success => true, :data =>  {:message => message}}
      end
    else
      clean_up_passwords resource
      messages = resource.errors.messages
      return render :json => {:success => false, :data =>  {:message => messages}}
    end
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :address, :phone, :name_company)
  end
end
