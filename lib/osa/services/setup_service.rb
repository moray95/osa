# frozen_string_literal: true
require 'osa/util/db'
require 'osa/services/auth_service'
require 'tty-prompt'
require 'osa/util/context'

module OSA
  class SetupService
    def setup!
      Config.delete_all
      config = Config.new
      AuthService.login(config)

      context = Context.new(config)
      folders = context.graph_client.folders.all
      choices = folders.map { |folder|
        [folder['displayName'], folder['id']]
      }.to_h
      prompt = TTY::Prompt.new
      junk_folder_id = prompt.select('Select junk folder:', choices)
      spamcop_email = prompt.ask('Spamcop report email:') { |q| q.validate :email }

      config.update! junk_folder_id: junk_folder_id, spamcop_report_email: spamcop_email
    end
  end
end
