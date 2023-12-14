# frozen_string_literal: true

require_relative 'discount'
require_relative '../filters/products/by_code'
require 'pry'

module Discounts
  class BuyNGetNFree < Discount
    def apply(products)
      @products = ::Filters::Products::ByCode.filter(products, product_code)
      @products_to_discount = []

      return unless @products.any?

      remove_discounts

      return unless discount_eligible?

      @products.each { |product| products_to_discount << product if limit_not_exceeded? }
      discount_products
    end

    # accessor?
    attr_reader :products_to_discount

    private

    def matching_products
      @matching_products ||= []
    end

    def validate_specific_discount_properties
      validate_free_quantity
    end

    def validate_free_quantity
      free_quantity = discount_properties['free_quantity']

      raise 'Free quantity not specified' if free_quantity.nil?
      raise 'Free quantity should be a positive integer' unless free_quantity.is_a?(Integer) && free_quantity.positive?
      raise 'Free quantity should be less than threshold quantity' if free_quantity >= threshold_quantity
    end

    def limit_not_exceeded?
      products_to_discount.count < max_quantity_to_discount
    end

    def max_quantity_to_discount
      (products.count / threshold_quantity) * free_quantity
    end

    def free_quantity
      discount_properties['free_quantity'].to_i
    end

    def discount_products
      products_to_discount.each do |product|
        product['discount'] = product['price']
      end
    end
  end
end
