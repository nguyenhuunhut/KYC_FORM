class Users::PasswordsController < Devise::PasswordsController
    # prepend_before_action :require_no_authentication
    # # Render the #edit only if coming from a reset password email link
    # append_before_action :assert_reset_token_passed, only: :edit
    respond_to :json


    def create
      if self.resource = resource_class.send_reset_password_instructions(password_params)
        message = find_message(:send_instructions)
        return  render json: {:success => true, :data => {:message => message}}
      else
        messages = resource.errors.messages
        return render json: {:success => false, :data => {:message => messages}}
      end
    end

    # GET /resource/password/edit?reset_password_token=abcdef
    # def edit
    #   self.resource = resource_class.new
    #   set_minimum_password_length
    #   resource.reset_password_token = params[:reset_password_token]
    # end


    def update
      self.resource = resource_class.reset_password_by_token(password_params)
      byebug

      yield resource if block_given?

      if resource.errors.empty?

        if Devise.sign_in_after_reset_password
          
          message = find_message(resource.active_for_authentication? ? :updated : :updated_not_active)
          sign_in(resource_name, resource)
          return render :json => {:message => message}
        else
          message = find_message(:notice, :updated_not_active)
          return render :json => {:message => message}
        end
        respond_with resource, location: after_resetting_password_path_for(resource)
      else
        messages = resource.errors.messages
        return render :json => {:message => messages}
        respond_with resource
      end
    end


      # def after_resetting_password_path_for(resource)
      #   Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
      # end
      #
      # # The path used after sending reset password instructions
      # def after_sending_reset_password_instructions_path_for(resource_name)
      #   new_session_path(resource_name) if is_navigational_format?
      # end
      #
      # # Check if a reset_password_token is provided in the request
      # def assert_reset_token_passed
      #   if params[:reset_password_token].blank?
      #     set_flash_message(:alert, :no_token)
      #     redirect_to new_session_path(resource_name)
      #   end
      # end

      # Check if proper Lockable module methods are present & unlock strategy
      # allows to unlock resource on password reset
      # def unlockable?(resource)
      #   resource.respond_to?(:unlock_access!) &&
      #     resource.respond_to?(:unlock_strategy_enabled?) &&
      #     resource.unlock_strategy_enabled?(:email)
      # end
      #
      # def translation_scope
      #   'devise.passwords'
      # end

      def password_params
        params.require(:password).permit(:email, :password, :password_confirmation, :reset_password_token)
      end
end
