# frozen_string_literal: true

require_relative 'product_factory'

module Products
  extend Forwardable

  class Product
    def initialize(code:, name:, price:, discount: nil)
      @code = code
      @name = name
      @price = price
      @discount = discount
    end

    def self.build(product)
      ProductFactory.build(product)
    end

    attr_accessor :code, :name, :price, :discount
  end
end
