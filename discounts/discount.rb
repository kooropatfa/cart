# frozen_string_literal: true

module Discounts
  TYPES_MAPPING = {
    'buy_n_get_n_free' => 'BuyNGetNFree',
    'bulk' => 'Bulk'
  }.freeze

  class Discount
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
      validate_type
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

    def validate_type
      type = discount_properties['type']

      raise 'Discount type not specified' unless type
      raise "Discount type should be one of #{Discounts::TYPES_MAPPING.keys}" unless Discounts::TYPES_MAPPING[type]
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
