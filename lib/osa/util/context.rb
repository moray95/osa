# frozen_string_literal: true

require 'osa/clients/ms_auth_client'
require 'osa/services/auth_service'
require 'osa/clients/ms_graph_client'

module OSA
  class Context
    attr_reader :graph_client
    attr_reader :auth_service
    attr_reader :config

    def initialize(config=nil)
      @config = config || Config.first

      if @config.nil?
        $stderr.puts 'OSA not configured'
        exit 1
      end

      auth_client = MSAuthClient.new
      @auth_service = AuthService.new(auth_client)
      token = auth_service.refresh_token(@config)

      @graph_client = MSGraphClient.new(token['access_token'])
    end
  end
end
