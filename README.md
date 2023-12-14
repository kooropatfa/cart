This is my solution of the Technical Evaluation Challenge. 

This is a CLI ruby application written in ruby 3.2.2.
To run it, you need to have ruby installed on your machine and run the following command in the root directory of the project:

```ruby shop_runner.rb```

The application will display a list of products available in the shop and let you decide what would you like to do:
1. Add a product to the cart
2. Remove a product from the cart
3. View the cart summary
4. Exit the application

You have to confirm your choice by pressing enter.

If you'll choose `1` or `2`, you'll be asked to provide the product code. You can find the product codes in the list of products displayed at the beginning of the application. It will be also rendered after each action.

Cart summary allows to view the list of products in the cart, price of each product, total price of the cart and discounts applied to the cart if there are any to apply.

config.json can be modified:
- each product should have name, price and code
- each discount needs to have name, type, product_code and threshold_quantity. Additionally, Bulk discount have to specify one of `discount_fraction` or `fixed_price`, while BuyNgetNFree have to specify `free_quantity`
- products are matched with discounts by `product.code - discount.product_code` so to make discount appliable they need to match
- please keep in mind that discount types are mapped to the class names in the code so introducing new types of discounts will require code changes
  
And to run tests suite type `rspec spec`.

Have fun :)



## Technical Evaluation Problem Desciption

You are the developer in charge of building a cash register.
This app will be able to add products to a cart and compute the total price.

## Objective

Build an application responding to these needs.

By application, we mean:
- It can be a CLI application to run in command line
- It is usable while remaining as simple as possible
- It is simple
- It is readable
- It is maintainable
- It is easily extendable

## Technical requirements

- Use any of those languages you are comfortable (Ruby, Python, Go, .Net Core)
- Covered by tests
- Following TDD methodology

## Description

### Assumptions

**Products Registered**
| Product Code | Name | Price |  
|--|--|--|
| GR1 |  Green Tea | 3.11€ |
| SR1 |  Strawberries | 5.00 € |
| CF1 |  Coffee | 11.23 € |

**Special conditions**

- The CEO is a big fan of buy-one-get-one-free offers and green tea.
He wants us to add a  rule to do this.

- The COO, though, likes low prices and wants people buying strawberries to get a price  discount for bulk purchases.
If you buy 3 or more strawberries, the price should drop to 4.50€.

- The VP of Engineering is a coffee addict.
If you buy 3 or more coffees, the price of all coffees should drop to 2/3 of the original price.

Our check-out can scan items in any order, and because the CEO and COO change their minds  often, it needs to be flexible regarding our pricing rules.

**Test data**
| Basket | Total price expected |  
|--|--|
| GR1,GR1 |  3.11€ |
| SR1,SR1,GR1,SR1 |  16.61€ |
| GR1,CF1,SR1,CF1,CF1 |  30.57€ |


**Deliverable**

The codebase in a shared folder we can access or a public git repository

**Things we are going to look into or ask about**

- Best practices  
- Commit history  
- Code structure and flow  
- Facility To make some changes to the code
- A proper readme with good explanation
amenitiz-technical-challenge.md
Wyświetlanie amenitiz-technical-challenge.md.
