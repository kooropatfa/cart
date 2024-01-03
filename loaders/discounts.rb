# frozen_string_literal: true

require 'json'

require_relative '../discounts/discount'
require_relative '../discounts/buy_n_get_n_free'
require_relative '../discounts/bulk'

module Loaders
  class Discounts
    class DiscountConfig < Hash
      def initialize(discount_hash)
        super.merge!(discount_hash)
      end

      def self.load
        discounts_json = JSON.parse(File.read('config.json'))['discounts']
        discounts_json
        .map { |discount_hash| DiscountConfig.new(discount_hash) }
        .map { |discount_config| ::Discounts::Discount::Factory.build(discount_config) }
      end

      def type
        self['type']
      end
    end
  end
end
