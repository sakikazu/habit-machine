module Api
  module V1
    class ApiController < ActionController::API
      # authenticate_with_http_tokenを使うために
      include ActionController::HttpAuthentication::Token::ControllerMethods

      def authenticate_user_for_api
        # NOTE: "authenticate_or_request_with_http_token" リクエストヘッダーの「Authorization: Token XXXX」という情報からトークンを抜き出し、
        # メソッドの戻り値がfalseの場合は自動でエラーのレスポンスを作ってくれる
        authenticate_or_request_with_http_token do |token, options|
          @current_user = User.find_by(auth_token: token)
          if @current_user.present?
            sign_in @current_user
            true
          else
            false
          end
        end
      end
    end
  end
end

