# frozen_string_literal: true

require 'json'

require_relative '../discounts/discount'
require_relative '../discounts/buy_n_get_n_free'
require_relative '../discounts/bulk'

module Loaders
  class Discounts
    def initialize
      discounts_json = JSON.parse(File.read('config.json'))['discounts']
      @discounts = discounts_json.map do |discount|
        type = type(discount)
        discount_class_name = discount_class_name_for(type)

        raise "Unknown discount type: #{type}" unless discount_class_name

        discount_class = ::Discounts.const_get(discount_class_name)
        discount_class.new(discount)
      end
    end

    attr_reader :discounts

    private

    def discount_class_name_for(type)
      ::Discounts::TYPES_MAPPING[type]
    end

    def type(discount)
      discount['type']
    end
  end
end
