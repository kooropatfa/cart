# frozen_string_literal: true

require 'spec_helper'
require_relative '../../loaders/discounts'

describe Loaders::Discounts do
  subject { described_class.new }

  describe '#initialize' do
    context 'when the discount type is known' do
      it 'loads the discounts from the config file' do
        discounts_classes_list = [::Discounts::BuyNGetNFree, ::Discounts::Bulk, ::Discounts::Bulk]

        expect(subject.discounts.map(&:class)).to match_array(discounts_classes_list)
      end
    end

    context 'when the discount type is unknown' do
      let(:type) { 'buy_2_pay_for_3' }

      before do
        allow_any_instance_of(described_class).to receive(:type).with(anything).and_return(type)
        allow_any_instance_of(described_class).to receive(:discount_class_name_for).with(type).and_return(nil)
      end

      it 'raises an error' do
        expect { subject }.to raise_error("Unknown discount type: #{type}")
      end
    end
  end
end
