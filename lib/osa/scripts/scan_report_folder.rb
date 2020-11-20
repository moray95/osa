# frozen_string_literal: true
require 'uri'
require 'public_suffix'
require 'osa/util/db'
require 'osa/util/context'

context = OSA::Context.new

loop do
  mails = context.graph_client.mails(context.config.report_folder_id)
  break if mails['value'].empty?
  mails['value'].each do |mail|
    email_address = mail['sender']['emailAddress']['address']

    puts "forwarding spam from #{email_address}"
    context.graph_client.forward_mail_as_attachment(mail['id'], context.config.spamcop_report_email)
    puts "deleting spam from #{email_address}"
    context.graph_client.delete_mail(mail['id'])


    next if email_address.nil?
    domain = PublicSuffix.domain(email_address.split('@', 2)[1])

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
