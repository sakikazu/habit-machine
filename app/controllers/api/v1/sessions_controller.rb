module Api
  module V1
    class SessionsController < ApiController
      def create
        @user = User.find_for_database_authentication(email: params[:email])
        return invalid_email unless @user

        if @user.valid_password?(params[:password])
          # TODO: sign_inする必要性ってあるのかな？
          sign_in :user, @user
          @user.regenerate_auth_token
          render json: { token: @user.auth_token }, status: 200
          # render json: @user, serializer: SessionSerializer, root: nil
        else
          invalid_password
        end
      end

      private

      def invalid_email
        # TODO: これは何のためのもの？
        warden.custom_failure!
        render json: { error: t('invalid_email') }, status: :unauthorized
      end

      def invalid_password
        warden.custom_failure!
        render json: { error: t('invalid_password') }, status: :unauthorized
      end
    end
  end
end

