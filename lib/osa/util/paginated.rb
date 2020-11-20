# frozen_string_literal: true

module OSA
  class Paginated
    def initialize(value, client)
      @value = value
      @client = client
    end

    def next
      next_page = @value['@odata.nextLink']
      return nil if next_page.nil?
      Paginated.new(@client.get(next_page), @client)
    end

    def all
      value = @value['value'].dup
      next_page = self.next
      until next_page.nil?
        value += next_page['value']
        next_page = next_page.next
      end
      value
    end

    private
      def method_missing(symbol, *args)
        @value.send(symbol, *args)
      end
  end
end
