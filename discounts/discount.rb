# frozen_string_literal: true

module Discounts
  TYPES_MAPPING = Hash.new('NoSuchDiscountType').merge(
    'buy_n_get_n_free' => 'BuyNGetNFree',
    'bulk' => 'Bulk'
  ).freeze

  class Discount
    class Factory
      def self.build(discount_config)
        type = discount_config.type

        Discounts.const_get(Discounts::TYPES_MAPPING[type]).new(discount_config)
      rescue NameError
        raise "Unknown discount type: #{type}" 
      end
    end

    def initialize(properties)
      raise 'Discount properties not specified' if properties.nil? || properties.empty?
      raise 'Discount properties should be a hash' unless properties.is_a?(Hash)

      @discount_properties = properties
      @matching_products_count = 0

      validate_general_discount_properties
      validate_specific_discount_properties
    end

    def apply(products)
      raise NotImplementedError, 'Should be implemented in child classes'
    end

    attr_reader :discount_properties,
                :products

    private

    def validate_general_discount_properties
      validate_threshold
      validate_product_code
    end

    def validate_specific_discount_properties
      raise NotImplementedError, 'Should be implemented in child classes'
    end

    def validate_threshold
      threshold = discount_properties['threshold_quantity']

      raise 'Discount threshold quantity not specified' if threshold.nil?
      unless threshold.is_a?(Integer) && threshold.positive?
        raise 'Discount threshold quantity should be a positive integer'
      end

      p "WARNING! Dicount threshold for #{discount_properties['name']} is set to 0" if threshold_quantity.zero?
    end

    def validate_product_code
      raise 'Discount product code not specified' if product_code.nil? || product_code.gsub(' ', '').empty?
    end

    def product_code
      @product_code ||= discount_properties['product_code']
    end

    def threshold_quantity
      @threshold_quantity ||= discount_properties['threshold_quantity'].to_i
    end

    def discount_eligible?
      products.count >= threshold_quantity
    end

    def remove_discounts
      products.each do |product|
        product.delete('discount') if product['code'] == product_code
      end
    end
  end
end
