# frozen_string_literal: true
require 'osa/util/db'
require 'uri'
require 'tty-prompt'

module OSA
  class AuthService
    def initialize(client)
      @client = client
    end

    def refresh_token(config)
      token = @client.refresh_token(config.refresh_token)
      config.update!(refresh_token: token['refresh_token'])
      token
    end

    def code_token(code, config)
      token = @client.code_token(code)
      config.update!(refresh_token: token['refresh_token'])
      token
    end

    def self.login(config)
      query = {
        client_id: CLIENT_ID,
        response_type: 'code',
        redirect_uri: REDIRECT_URL,
        response_mode: 'query',
        scope: SCOPE,
        state: ''
      }

      query_str = query.reduce('?') do |acc, val|
        key, value = val
        acc + "#{key}=#{URI.encode_www_form_component(value)}&"
      end

      base_uri = 'https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize'

      uri = "#{base_uri}#{query_str}"
      puts 'Open the following url in your browser and enter the authentication code displayed.'
      puts uri

      prompt = TTY::Prompt.new
      code = prompt.ask('Code:')

      auth_client = MSAuthClient.new
      auth_service = AuthService.new(auth_client)

      auth_service.code_token(code, config)

      puts 'login completed'
    end
  end
end
