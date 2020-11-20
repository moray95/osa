# frozen_string_literal: true
require 'active_record/migration'

class CreateConfig < ActiveRecord::Migration[5.0]
  def change
    create_table :config do |t|
      t.text :refresh_token
      t.text :junk_folder_id
      t.text :report_folder_id
      t.text :spamcop_report_email
    end
  end
end
