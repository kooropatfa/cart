# frozen_string_literal: true

module Products
  class Product
    def self.build(product)
      new(
        code: product['code'],
        name: product['name'],
        price: product['price'],
        discount: product['discount']
      )
    end

    attr_accessor :code, :name, :price, :discount

    def initialize(code:, name:, price:, discount: nil)
      @code = code
      @name = name
      @price = price
      @discount = discount
    end
  end
end