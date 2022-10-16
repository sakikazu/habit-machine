module Google
  # ref:
  #   - GoogleAPIの認可処理についてわかりやすい https://qiita.com/chenglin/items/f2382898a8cf85bec8dd
  #   - rubyライブラリがあるみたいだが未使用 https://developers.google.com/identity/protocols/oauth2/web-server
  #   - 実際のAPIのRequest/Responseが見れる https://developers.google.com/oauthplayground/
  #
  # NOTE: Google OAuthで必要な情報とその結果
  #   - [クライアントID] + [スコープ] = Authorization code
  #   - [クライアントID] + [クライアントシークレット] + [Authorization code] = アクセストークン、リフレッシュトークン
  #   - [クライアントID] + [クライアントシークレット] + [リフレッシュトークン] = アクセストークン
  class Calendar
    class RefreshTokenExpiredError < StandardError; end

    # TODO: sessionをモデルで使ったり、sessionに保存処理や、一つのメソッドで色々やってたりと、良くない設計 リファクタリングしたい
    # TODO: ジョブに任せた方が良い気もする。consoleからAPI実行できるような作りに
    def initialize(session = nil)
      RestClient.log = STDOUT if Rails.env.development?
      @session = session
    end

    # TODO: block使ってもっとわかりやすくできる気がする。データ取得とアクセストークンの再取得をやってるのでよくない
    def fetch_recent_events_with_refreshing_token(refresh_token)
      return [] if @session[:gcp_access_token].blank?
      fetch_recent_events(access_token: @session[:gcp_access_token])
    rescue RestClient::ExceptionWithResponse => e
      # アクセストークンの有効期限切れ
      if e.http_code == 401
        Rails.logger.error '[Google Calendar] access_token is expired!'
        if refresh_token.present?
          refresh_access_token(refresh_token: refresh_token)
          retry
        end
      else
        raise e
      end
    end

    def auth_uri
      query_params = {
        scope: scope,
        access_type: 'offline',
        include_granted_scopes: true,
        redirect_uri: callback_uri,
        response_type: 'code',
        client_id: client_id
      }
      'https://accounts.google.com/o/oauth2/v2/auth?' + query_params.to_query
    end

    # code: 認可コード
    def fetch_access_token(code:)
      host = 'https://oauth2.googleapis.com/token'
      params = {
        code: code,
        redirect_uri: callback_uri, # 不要そうだが、つけないと `400 BadRequest`
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'authorization_code'
      }
      res = RestClient.post(host, params, base_headers)
      body = JSON.parse(res.body)
      @session[:gcp_access_token] = body["access_token"]
      body["refresh_token"]
    end

    def refresh_access_token(refresh_token:)
      host = 'https://oauth2.googleapis.com/token'
      params = {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'refresh_token',
        refresh_token: refresh_token
      }
      res = RestClient.post(host, params, base_headers)
      body = JSON.parse(res.body)
      @session[:gcp_access_token] = body["access_token"]
      @session[:gcp_access_token]
    rescue RestClient::ExceptionWithResponse => e
      # リフレッシュトークンの有効期限切れ
      if e.http_code == 401
        Rails.logger.error '[Google Calendar] refresh_token is expired!'
        raise RefreshTokenExpiredError, 'リフレッシュトークンの有効期限切れ'
      end
    end

    def fetch_recent_events(access_token:)
      # NOTE: fetch_calendar_list で取得したカレンダーのidを指定すれば任意のカレンダーのものが取得できる
      calendar_id = 'primary'
      calendar_url = "https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events"
      query_params = {
        maxResults: 10,
        orderBy: 'startTime',
        singleEvents: true,
        showDeleted: false,
        timeMin: Time.zone.today.to_time.in_time_zone('UTC').strftime('%Y-%m-%dT%H:%M:%SZ')
      }
      params = headers_with_token(access_token).merge(params: query_params)
      res = RestClient.get(calendar_url, params)
      body = JSON.parse(res.body)
      body["items"].map do |item|
        {
          title: item['summary'],
          start_time: Time.zone.parse(item['start']['dateTime'])
        }
      end
    end

    def fetch_calendar_list(access_token:)
      calendar_url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList'
      query_params = {
        maxResults: 100
      }
      params = headers_with_token(access_token).merge(params: query_params)
      res = RestClient.get(calendar_url, params)
      body = JSON.parse(res.body)
      body["items"]
    end

    def callback_uri
      host = Rails.application.config.action_mailer.default_url_options[:host]
      port = Rails.application.config.action_mailer.default_url_options[:port]
      Rails.application.routes.url_helpers.google_callback_url(host: host, port: port)
    end

    def scope
      'https://www.googleapis.com/auth/calendar.readonly'
    end

    def client_id
      Settings.google_oauth.client_id
    end

    def client_secret
      Settings.google_oauth.client_secret
    end

    def base_headers
      {
        content_type: 'application/x-www-form-urlencoded'
      }
    end

    def headers_with_token(access_token)
      base_headers.merge(authorization: "Bearer #{access_token}")
    end
  end
end
