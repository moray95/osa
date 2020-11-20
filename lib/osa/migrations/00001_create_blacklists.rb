# frozen_string_literal: true
require 'active_record/migration'

class CreateBlacklists < ActiveRecord::Migration[5.0]
  def change
    create_table :blacklists do |t|
      t.text :value, unique: true
    end
  end
end
