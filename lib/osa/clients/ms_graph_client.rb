# frozen_string_literal: true
require 'faraday'
require 'json'
require 'base64'
require 'osa/util/paginated'
require 'osa/clients/http_client'
require 'active_support/core_ext/numeric/bytes'
require 'active_support'

module OSA
  class MSGraphClient
    URL = 'https://graph.microsoft.com'

    def initialize(token)
      @authenticated = HttpClient.new(Faraday.new(
        url: 'https://graph.microsoft.com',
        headers: {
          'authorization' => "Bearer #{token}"
        }
      ))

      @unauthenticated = HttpClient.new(Faraday.new(
        url: 'https://graph.microsoft.com'
      ))
    end

    def rules
      @authenticated.get('/v1.0/me/mailFolders/inbox/messageRules')
    end

    def rule(id)
      @authenticated.get("/v1.0/me/mailFolders/inbox/messageRules/#{id}")
    end

    def folders
      Paginated.new(@authenticated.get('/v1.0/me/mailFolders'), self)
    end

    def mails(folder_id)
      Paginated.new(@authenticated.get("/v1.0/me/mailFolders/#{folder_id}/messages"), self)
    end

    def raw_mail(mail_id)
      @authenticated.get("/v1.0/me/messages/#{mail_id}/$value")
    end

    def forward_mail_as_attachment(mail_id, to)
      raw_mail = self.raw_mail(mail_id)
      forward_message = create_forward_message(mail_id)
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
      add_email_attachment(forward_message['id'], 'email.eml', raw_mail)
      send_message(forward_message['id'])
    end

    def create_forward_message(mail_id)
      @authenticated.post("/v1.0/me/messages/#{mail_id}/createForward")
    end

    def add_email_attachment(mail_id, name, content)
      if content.length < 3.megabytes
        add_small_email_attachment(mail_id, name, content)
      else
        add_large_email_attachment(mail_id, name, content)
      end
    end

    def delete_mail(mail_id)
      @authenticated.delete("/v1.0/me/messages/#{mail_id}")
    end

    def update_rule(id, update)
      @authenticated.patch("/v1.0/me/mailFolders/inbox/messageRules/#{id}", update.to_json, 'content-type' => 'application/json')
    end

    def update_message(id, update)
      @authenticated.patch("/v1.0/me/messages/#{id}", update.to_json, 'content-type': 'application/json')
    end

    def send_message(id)
      @authenticated.post("/v1.0/me/messages/#{id}/send")
    end

    private
      def add_small_email_attachment(mail_id, name, content)
        body = {
          "@odata.type": '#microsoft.graph.fileAttachment',
          contentBytes: Base64.encode64(content),
          name: name
        }
        @authenticated.post("/v1.0/me/messages/#{mail_id}/attachments", body.to_json, 'content-type': 'application/json')
      end

      def add_large_email_attachment(mail_id, name, content)
        upload_session = create_upload_session(mail_id, name, content.length)
        ranges = upload_session['nextExpectedRanges'].map do |range|
          range.split('-').then { |start, finish| (start.to_i..finish&.to_i) }
        end
        ranges.each do |range|
          current_content = content[range]
          @unauthenticated.put(upload_session['uploadUrl'], current_content[range], 'Content-Range': "bytes #{range.begin}-#{(range.end || content.length) - 1}/#{content.length}")
        end
      end

      def create_upload_session(mail_id, name, size)
        body = {
          AttachmentItem: {
            attachmentType: :file,
            name: name,
            size: size
          }
        }
        @authenticated.post("/v1.0/me/messages/#{mail_id}/attachments/createUploadSession", body.to_json, 'content-type': 'application/json')
      end
  end
end
