module Products
  class ProductFactory
    def self.build(product)
      Products::Product.new(
        code: product['code'],
        name: product['name'],
        price: product['price'],
        discount: product['discount']
      )
    end
  end
end