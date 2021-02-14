# frozen_string_literal: true
require 'sinatra'
require 'sinatra/json'
require 'osa/util/db'

class DashboardServer < Sinatra::Base
  set :views, File.absolute_path(File.dirname(__FILE__) + '/../views')
  set :port, ENV['SERVER_PORT'] || 8080

  get '/' do
    erb :index
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

  get '/api/stats/spammers' do
    spammers = OSA::Report.select('sender_domain as domain', 'COUNT(*) as count').limit(50).order(count: :desc).group(:sender_domain)
    json spammers
  end

  get '/api/stats/reports/historical' do
    historical_data = OSA::Report.select("strftime('%Y-%m-%d', reported_at) as date", 'count(*) as count').group(:date)
    json historical_data
  end
end
