# frozen_string_literal: true

require 'bigdecimal'

require_relative 'discount'
require_relative '../filters/products/by_code'
require_relative '../loaders/products'

module Discounts
  class Bulk < Discount
    DISCOUNT_METHODS = %w[discount_fraction fixed_price].freeze

    def apply(products)
      @products = Filters::Products::ByCode.filter(products, product_code)

      return unless @products.any?

      discount_products if discount_eligible?
    end

    attr_reader :discount_fraction, :fixed_price

    private

    def validate_specific_discount_properties
      validate_discount_method
    end

    attr_reader :discount_method

    def discount_fraction
      @discount_fraction ||= discount_properties['discount_fraction']
    end

    def fixed_price
      @fixed_price ||= discount_properties['fixed_price']
    end

    def validate_discount_method
      discount_methods = discount_properties.slice(*DISCOUNT_METHODS).map { |method, value| method if value }.compact

      raise "Specify exactly one of following discount methods: #{DISCOUNT_METHODS}" if discount_methods.count != 1

      @discount_method = discount_methods.first

      raise "Value not specified for #{discount_method}" if discount_properties[discount_method].nil?

      validate_discount_method_value

      true
    end

    def validate_discount_method_value
      case discount_method
      when 'discount_fraction'
        validate_discount_fraction
      when 'fixed_price'
        validate_fixed_price
      end
    end

    def validate_discount_fraction
      fraction_pattern = %r{\A\s*(\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)\s*\z}

      raise 'Discount fraction should be a positive fraction' unless discount_fraction.match(fraction_pattern)
      raise 'Denominator cannot be zero' if discount_fraction.split('/')[1].to_i.zero?

      fraction = Rational(discount_fraction).to_f
      raise 'Discount fraction should be less than 1 and more than 0' if fraction >= 1 || fraction <= 0
    end

    def validate_fixed_price
      raise 'Fixed price should be an integer' unless fixed_price.is_a?(Integer)
      raise 'Fixed price should be a positive integer' unless fixed_price.positive?
      raise 'Fixed price should be less than product price' if fixed_price >= product_price
    end

    def product_price
      @product ||= ::Loaders::Products.new.find_by_code(product_code)

      return unless @product

      @product_price ||= @product['price']
    end

    def discount_products
      products.each do |product|
        product.discount = calculate_discount
      end
    end

    def calculate_discount
      case discount_method
      when 'discount_fraction'
        calculate_fraction_discount
      when 'fixed_price'
        calculate_fixed_price_discount
      end
    end

    def calculate_fraction_discount
      numerator, denominator = discount_fraction.split('/').map { |n| BigDecimal(n) }
      fraction = numerator / denominator

      (product_price * fraction).round(0)
    end

    def calculate_fixed_price_discount
      product_price - fixed_price
    end
  end
end
