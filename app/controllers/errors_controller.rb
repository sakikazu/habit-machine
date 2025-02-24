class ErrorsController < ActionController::Base
  def show
    error = request.env["action_dispatch.exception"]

    case error
    when ActionController::RoutingError, ActiveRecord::RecordNotFound
      # TODO: application layoutでは current_userを使っているので、非ログイン状態でもページが表示できるよう、シンプルなレイアウトを指定すべき
      render template: "errors/404", status: 404, layout: 'application'
    when StandardError
      render template: "errors/500", status: 500, layout: 'application'
      # NOTE: 現状は権限管理はやってないはずなので、やる場合は有効にする
      # when SomeAuthorizationError
      # render template: "errors/403", status: 403, layout: 'application'
    end
  end
end
