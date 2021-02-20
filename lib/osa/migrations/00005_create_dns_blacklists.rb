# frozen_string_literal: true
require 'active_record/migration'

class CreateDnsBlacklists < ActiveRecord::Migration[5.0]
  def change
    create_table :dns_blacklists do |t|
      t.text :name, null: false
      t.text :server, null: false
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
        insert into dns_blacklists (name, server) values
          ('spamcop', 'bl.spamcop.net'),
          ('sbl', 'sbl.spamhaus.org'),
          ('psbl', 'psbl.surriel.org');
        SQL
        add_column :reports, :blacklist, :string, null: true
        execute <<~SQL
          update reports set blacklist = 'db' where blacklisted = true;
        SQL
        remove_column :reports, :blacklisted
      end

      dir.down do
        add_column :reports, :blacklisted, :boolean, default: false
        execute <<~SQL
          update reports set blacklisted = true where blacklist = 'db';
        SQL
        remove_column :reports, :blacklist
      end
    end
  end
end
