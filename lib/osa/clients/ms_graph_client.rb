# frozen_string_literal: true
require 'faraday'
require 'json'
require 'base64'
require 'osa/util/paginated'
require 'osa/clients/http_client'

module OSA
  class MSGraphClient < HttpClient
    def initialize(token)
      connection = Faraday.new(
        url: 'https://graph.microsoft.com',
        headers: {
          'authorization' => "Bearer #{token}"
        }
      )
      super connection
    end

    def rules
      get('/v1.0/me/mailFolders/inbox/messageRules')
    end

    def rule(id)
      get("/v1.0/me/mailFolders/inbox/messageRules/#{id}")
    end

    def folders
      Paginated.new(get('/v1.0/me/mailFolders'), self)
    end

    def mails(folder_id)
      Paginated.new(get("/v1.0/me/mailFolders/#{folder_id}/messages"), self)
    end

    def raw_mail(mail_id)
      get("/v1.0/me/messages/#{mail_id}/$value")
    end

    def forward_mail_as_attachment(mail_id, to)
      raw_mail = self.raw_mail(mail_id)
      forward_message = create_forward_message(mail_id)
      add_email_attachment(forward_message['id'], raw_mail)
      update = {
        toRecipients: [
          {
            emailAddress: {
              address: to
            }
          }
        ]
      }
      update_message(forward_message['id'], update)
      send_message(forward_message['id'])
    end

    def create_forward_message(mail_id)
      post("/v1.0/me/messages/#{mail_id}/createForward")
    end

    def add_email_attachment(mail_id, content)
      body = {
        "@odata.type": '#microsoft.graph.fileAttachment',
        "contentBytes": Base64.encode64(content),
        "name": 'email.eml'
      }
      post("/v1.0/me/messages/#{mail_id}/attachments", body.to_json, 'content-type': 'application/json')
    end

    def delete_mail(mail_id)
      delete("/v1.0/me/messages/#{mail_id}")
    end

    def update_rule(id, update)
      patch("/v1.0/me/mailFolders/inbox/messageRules/#{id}", update.to_json, 'content-type' => 'application/json')
    end

    def update_message(id, update)
      patch("/v1.0/me/messages/#{id}", update.to_json, 'content-type': 'application/json')
    end

    def send_message(id)
      post("/v1.0/me/messages/#{id}/send")
    end
  end
end
