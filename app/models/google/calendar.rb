module Google
  class Calendar
    def initialize
      RestClient.log = STDOUT
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

    # TODO: ここでsessionに保存する。
    # code: 認可コード
    def fetch_access_token(code)
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
      [body["access_token"], body["refresh_token"]]
    end

    # TODO: ここでsessionに保存する。
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
      body["access_token"]
    end

    def fetch_recent_events(access_token:)
      calendar_url = 'https://www.googleapis.com/calendar/v3/calendars/primary/events'
      query_params = {
        maxResults: 10,
        orderBy: 'startTime',
        singleEvents: true,
        showDeleted: false,
        timeMin: Time.zone.today.to_time.in_time_zone('UTC').strftime('%Y-%m-%dT%H:%M:%SZ')
      }
      params = base_headers.merge(authorization: "Bearer #{access_token}").merge(params: query_params)
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
  end
end
