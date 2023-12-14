# frozen_string_literal: true

require 'json'

module Loaders
  class Products
    def initialize
      @products = JSON.parse(File.read('config.json'))['products']

      raise 'No products found in config!' unless @products.any?
    end

    attr_accessor :products

    def by_code(code)
      products.find { |product| product['code'] == code }.dup
    end
  end
end
