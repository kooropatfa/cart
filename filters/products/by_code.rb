# frozen_string_literal: true

module Filters
  module Products
    class ByCode
      def self.filter(products, code)
        products.select { |product| product['code'] == code }
      end
    end
  end
end
