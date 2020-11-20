# frozen_string_literal: true
require 'osa/clients/http_client'
require 'faraday'
require 'osa/util/constants'

module OSA
  class MSAuthClient < HttpClient
    def initialize
      connection = Faraday.new(
        url: 'https://login.microsoft.com'
      )
      super connection
    end

    def code_token(code)
      body = {
        client_id: CLIENT_ID,
        scope: SCOPE,
        redirect_uri: REDIRECT_URL,
        grant_type: :authorization_code,
        code: code
      }
      post('/consumers/oauth2/v2.0/token', body, {})
    end

    def refresh_token(refresh_token)
      body = {
        client_id: CLIENT_ID,
        scope: SCOPE,
        refresh_token: refresh_token,
        grant_type: :refresh_token
      }
      post('/consumers/oauth2/v2.0/token', body)
    end
  end
end
