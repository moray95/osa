# frozen_string_literal: true
require 'osa/util/constants'
require 'public_suffix'
require 'osa/util/db'
require 'osa/util/context'
require 'public_suffix'

context = OSA::Context.new

continue = true

dns_blacklists = OSA::DnsBlacklist.all

def resolve_blacklist(mail_id, email_address, domain, context, dns_blacklists)
  return 'db' if OSA::Blacklist.where(value: email_address).or(OSA::Blacklist.where(value: domain)).exists?
  ip = context.graph_client.sender_ip(mail_id)
  if ip.nil?
    puts "Couldn't detect ip for email from #{email_address}"
    return nil
  end
  dns_blacklists.find { |bl| bl.blacklisted?(ip) }&.server
end

def extract_email_address(mail)
  email_address = mail['sender']['emailAddress']['address']
  return email_address unless email_address.nil?

  # Sometimes the SMTP From header is misformatted and the email address is
  # parsed as part of the name by Outlook. Try to extract the email address
  # from the name.
  sender_name = mail['sender']['emailAddress']['name']
  return nil if sender_name.nil?

  sender_name.scan(/<(.+@.+)>/).first&.first
end

while continue
  mails = context.graph_client.mails(context.config.junk_folder_id)
  continue = false
  loop do
    break if mails.nil?
    mails['value'].each do |mail|
      email_address = extract_email_address(mail)
      next if email_address.nil?
      domain = PublicSuffix.domain(email_address.split('@', 2)[1])

      flagged = mail['flag']['flagStatus'] == 'flagged'
      blacklist = (resolve_blacklist(mail['id'], email_address, domain, context, dns_blacklists) unless flagged)

      if flagged
        puts "Email from #{email_address} is flagged, reporting and deleting"
      elsif !blacklist.nil?
        puts "#{email_address} is blacklisted by #{blacklist}, reporting and deleting"
      else
        puts "Skipping mail from #{email_address}, its not blacklisted"
        next
      end

      continue = true

      puts "forwarding spam from #{email_address}"
      context.graph_client.forward_mail_as_attachment(mail['id'], context.config.spamcop_report_email)
      puts "deleting spam from #{email_address}"
      context.graph_client.delete_mail(mail['id'])

      OSA::Report.create!(sender: email_address,
                          sender_domain: domain,
                          subject: mail['subject'],
                          flagged: flagged,
                          blacklist: blacklist,
                          received_at: Time.iso8601(mail['receivedDateTime']),
                          reported_at: Time.now)

      # Do not add to the blacklist if the it's blacklisted by the db (it's already present)
      # or blacklisted by DNSBLs (these blacklists are only supposed to be temporary).
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
    end

    mails = mails.next
  end
end
