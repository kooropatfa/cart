# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../loaders/discounts'

# this test should use a config mock of a fixture file

describe Loaders::Discounts::DiscountConfig do

  describe '.load' do
    context 'when the discount type is known' do
      it 'loads the discounts from the config file' do
        discounts_classes_list = [::Discounts::BuyNGetNFree, ::Discounts::Bulk, ::Discounts::Bulk]

        expect(described_class.load).to match_array(discounts_classes_list)
      end
    end

    context 'when the discount type is unknown' do
      let(:type) { 'buy_2_pay_for_3' }

      before do
        allow_any_instance_of(described_class).to receive(:type).and_return(type)
      end

      it 'raises an error' do
        expect { described_class.load }.to raise_error("Unknown discount type: #{type}")
      end
    end
  end
end
