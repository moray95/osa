# frozen_string_literal: true
require 'active_record/migration'

class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.text :sender, null: false
      t.text :sender_domain, null: false
      t.text :subject, null: false
      t.boolean :flagged, null: false
      t.boolean :blacklisted, null: false
      t.datetime :received_at, null: false
      t.datetime :reported_at, null: false
    end
  end
end
