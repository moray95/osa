# frozen_string_literal: true
require 'active_record'
require 'resolv'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ENV['DATABASE'] || "#{Dir.pwd}/osa.db"
)
root = "#{File.dirname(__FILE__)}/../"
ActiveRecord::MigrationContext.new("#{root}/migrations", ActiveRecord::SchemaMigration).migrate

module OSA
  class Blacklist < ActiveRecord::Base
  end

  class Config < ActiveRecord::Base
    self.table_name = 'config'
  end

  class EmailProvider < ActiveRecord::Base
  end

  class Report < ActiveRecord::Base
  end

  class DnsBlacklist < ActiveRecord::Base
    def blacklisted?(ip)
      ::Resolv.getaddress("#{ip}.#{server}") != '0.0.0.0'
    rescue ::Resolv::ResolvError
      return false
    end
  end
end
