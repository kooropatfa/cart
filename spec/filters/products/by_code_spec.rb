# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../filters/products/by_code'

describe Filters::Products::ByCode do
  let(:products) do
    [
      { 'code' => 'PBZ', 'name' => 'Plumberry', 'price' => 100 },
      { 'code' => 'TBZ', 'name' => 'Testberry', 'price' => 1 },
      { 'code' => 'ABZ', 'name' => 'Appleberry', 'price' => 2 }
    ]
  end

  describe '.filter' do
    it 'returns products with matching code' do
      filtered_products = described_class.filter(products, 'PBZ')

      expect(filtered_products).to eq([{ 'code' => 'PBZ', 'name' => 'Plumberry', 'price' => 100 }])
    end

    it 'returns an empty array when no products match the code' do
      filtered_products = described_class.filter(products, 'XYZ')

      expect(filtered_products).to eq([])
    end
  end
end
