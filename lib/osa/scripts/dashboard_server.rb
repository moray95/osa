# frozen_string_literal: true
require 'sinatra'
require 'sinatra/json'
require 'osa/util/db'

class DashboardServer < Sinatra::Base
  set :views, File.absolute_path(File.dirname(__FILE__) + '/../views')
  set :port, ENV['SERVER_PORT'] || 8080
  after { ActiveRecord::Base.connection.close }

  get '/' do
    erb :index
  end

  get '/spammers/:spammer' do
    erb :spammer
  end

  get '/api/stats/summary' do
    blacklist_count = OSA::Blacklist.count
    total_reported = OSA::Report.count
    today = DateTime.now.to_date
    today_reported = OSA::Report.where('reported_at > ?', today).count
    week = DateTime.now - 1.week
    week_reported = OSA::Report.where('reported_at > ?', week).count
    month = DateTime.now - 30.days
    month_reported = OSA::Report.where('reported_at > ?', month).count
    mean_report_time = OSA::Report.select('avg(julianday(reported_at) - julianday(received_at)) * 86400.0 as avg').first['avg']

    json blacklist_count: blacklist_count,
         total_reported: total_reported,
         today_reported: today_reported,
         week_reported: week_reported,
         month_reported: month_reported,
         mean_report_time: mean_report_time

  end

  get '/api/stats/spammers/:spammer/summary' do |spammer|
    reports = OSA::Report.where(sender: spammer).or(OSA::Report.where(sender_domain: spammer))
    total_reported = reports.count
    today = DateTime.now.to_date
    today_reported = reports.where('reported_at > ?', today).count
    week = DateTime.now - 1.week
    week_reported = reports.where('reported_at > ?', week).count
    month = DateTime.now - 30.days
    month_reported = reports.where('reported_at > ?', month).count
    domains = reports.select(:sender).distinct.map { |e| e.sender.split('@', 2)[1] }
    domains.uniq!

    json total_reported: total_reported,
         today_reported: today_reported,
         week_reported: week_reported,
         month_reported: month_reported,
         domains: domains
  end

  get '/api/stats/spammers' do
    spammers = OSA::Report.select('sender_domain as domain', 'COUNT(*) as count')
    unless params[:interval].blank?
      spammers = spammers.where('received_at > ?', Time.now - params[:interval].to_i.days)
    end
    spammers = spammers.limit(50).order(count: :desc).group(:sender_domain)
    json spammers
  end

  get '/api/stats/reports/historical' do
    historical_data = OSA::Report.select("strftime('%Y-%m-%d', reported_at) as date", 'count(*) as count')
    unless params[:spammer].blank?
      historical_data = historical_data.where(sender: params[:spammer]).or(OSA::Report.where(sender_domain: params[:spammer]))
    end
    unless params[:interval].blank?
      historical_data = historical_data.where('received_at > ?', Time.now - params[:interval].to_i.days)
    end
    json historical_data.group(:date)
  end
end
