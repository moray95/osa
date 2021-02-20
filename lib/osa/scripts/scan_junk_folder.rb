# frozen_string_literal: true
require 'osa/util/constants'
require 'public_suffix'
require 'osa/util/db'
require 'osa/util/context'
require 'public_suffix'

context = OSA::Context.new

continue = true

while continue
  mails = context.graph_client.mails(context.config.junk_folder_id)
  continue = false
  loop do
    break if mails.nil?
    mails['value'].each do |mail|
      email_address = mail['sender']['emailAddress']['address']
      next if email_address.nil?
      domain = PublicSuffix.domain(email_address.split('@', 2)[1])

      flagged = mail['flag']['flagStatus'] == 'flagged'
      blacklisted = OSA::Blacklist.where(value: email_address).or(OSA::Blacklist.where(value: domain)).exists?

      if flagged
        puts "Email from #{email_address} is flagged, reporting and deleting"
      elsif blacklisted
        puts "#{email_address} is blacklisted, reporting and deleting"
      else
        puts "Skipping mail from #{email_address}, its not blacklisted"
        next
      end

      continue = true

      puts "forwarding spam from #{email_address}"
      context.graph_client.forward_mail_as_attachment(mail['id'], context.config.spamcop_report_email)
      puts "deleting spam from #{email_address}"
      context.graph_client.delete_mail(mail['id'])

      domain = PublicSuffix.domain(email_address.split('@', 2)[1])

      if flagged
        is_free_provider = OSA::EmailProvider.where(value: domain).exists?
        if is_free_provider
          puts "#{email_address} is using a free provider, blacklisting full address"
          OSA::Blacklist.find_or_create_by(value: email_address).save!
        else
          puts "Adding #{domain} to blacklist"
          OSA::Blacklist.find_or_create_by(value: domain).save!
        end
      end

      OSA::Report.create!(sender: email_address,
                     sender_domain: domain,
                     subject: mail['subject'],
                     flagged: flagged,
                     blacklisted: blacklisted,
                     received_at: Time.iso8601(mail['receivedDateTime']),
                     reported_at: Time.now)
    end
    mails = mails.next
  end
end
