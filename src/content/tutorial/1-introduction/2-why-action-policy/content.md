---
type: lesson
title: Why Action Policy?
editor: false
terminal: false
---

# Why Action Policy?

You might wonder: "Why do I need a gem for authorization? Can't I just write some `if` statements in my controllers?"

You could, but let's see why Action Policy is a better choice.

## The Problem with DIY Authorization

Consider this common pattern in Rails controllers:

```ruby
class ProductsController < ApplicationController
  def update
    @product = Product.find(params[:id])

    # DIY authorization - scattered logic
    unless current_user.admin? || @product.user_id == current_user.id
      redirect_to products_path, alert: "Not authorized"
      return
    end

    @product.update(product_params)
  end

  def destroy
    @product = Product.find(params[:id])

    # Same logic repeated!
    unless current_user.admin? || @product.user_id == current_user.id
      redirect_to products_path, alert: "Not authorized"
      return
    end

    @product.destroy
  end
end
```

This approach has several problems:

1. **Code duplication** - Authorization logic is repeated across actions
2. **Hard to test** - Testing requires full controller setup
3. **Hidden business rules** - Authorization logic is buried in controller code
4. **Inconsistent handling** - Different developers handle failures differently
5. **No visibility in views** - Hard to hide/show UI elements based on permissions

## The Action Policy Solution

With Action Policy, the same authorization becomes clean and organized:

```ruby
# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user_id == user.id
  end

  alias_rule :destroy?, to: :update?
end

# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  def update
    @product = Product.find(params[:id])
    authorize! @product  # One line!
    @product.update(product_params)
  end

  def destroy
    @product = Product.find(params[:id])
    authorize! @product
    @product.destroy
  end
end
```

## Key Benefits

### 1. Single Responsibility
Policies have one job: define authorization rules. Controllers focus on handling requests.

### 2. Easy Testing
Test policies in isolation, without HTTP requests or controller setup:

```ruby
describe ProductPolicy do
  let(:user) { User.new(admin: false) }
  let(:product) { Product.new(user_id: user.id) }

  it "allows users to update their own products" do
    policy = ProductPolicy.new(product, user: user)
    expect(policy.update?).to be true
  end
end
```

### 3. Convention Over Configuration
Action Policy automatically:
- Finds the right policy class (`Product` -> `ProductPolicy`)
- Infers the rule from action name (`update` -> `update?`)
- Uses `current_user` as the default subject

### 4. View Helpers
Easily show/hide UI elements:

```erb
<% if allowed_to?(:edit?, @product) %>
  <%= link_to "Edit", edit_product_path(@product) %>
<% end %>
```

### 5. Rich Feature Set
- **Aliases** - Avoid duplicating similar rules
- **Pre-checks** - Add admin bypass or other global checks
- **Scoping** - Filter records based on user permissions
- **Failure reasons** - Know exactly why authorization failed
- **I18n support** - Localized error messages
- **Caching** - Optimize repeated checks

Now that you understand the benefits, let's install Action Policy and create our first policy!
