module Api
  module V1
    class ApiController < ActionController::API
      # authenticate_with_http_tokenを使うために
      include ActionController::HttpAuthentication::Token::ControllerMethods

      def authenticate_user_for_api
        # NOTE: "authenticate_or_request_with_http_token" リクエストヘッダーの「Authorization: Token XXXX」という情報からトークンを抜き出し、
        # メソッドの戻り値がfalseの場合は自動でエラーのレスポンスを作ってくれる
        authenticate_or_request_with_http_token do |token, options|
          user = User.find_by(auth_token: token)
          if user.present?
            # NOTE: sign_inするとcurrent_userが使える模様。ログイン時間の更新も行っている。
            sign_in user
            true
          else
            false
          end
        end
      end
    end
  end
end

