# frozen_string_literal: true
require 'active_record/migration'

class CreateEmailProviders < ActiveRecord::Migration[5.0]
  def change
    create_table :email_providers do |t|
      t.text :value, unique: true
    end

    reversible do |dir|
      file = "#{File.dirname(__FILE__)}/free-email-providers.txt"
      dir.up do
        File.open(file).each do |provider|
          execute "insert into email_providers (value) values (\"#{provider.strip}\")"
        end
      end
      dir.down do
      end
    end
  end
end
