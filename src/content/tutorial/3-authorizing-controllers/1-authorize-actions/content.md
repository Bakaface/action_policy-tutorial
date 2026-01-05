---
type: lesson
title: Using authorize!
focus: /workspace/store/app/controllers/products_controller.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Using authorize!

Now that we have a policy, let's use it in our controller. The `authorize!` method is the primary way to enforce authorization.

## How authorize! Works

When you call `authorize!`, Action Policy:

1. **Finds the policy class** - `Product` -> `ProductPolicy`
2. **Infers the rule** - `show` action -> `show?` rule
3. **Gets the user** - Uses `current_user` by default
4. **Checks the rule** - Calls `ProductPolicy#show?`
5. **Raises on failure** - Throws `ActionPolicy::Unauthorized` if the rule returns `false`

## Add Authorization to the Controller

Open `app/controllers/products_controller.rb` and add `authorize!` calls:

```ruby ins={6,10}
class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
    authorize! @products
  end

  def show
    authorize! @product
  end

  # ... rest of the controller
end
```

:::tip
For `index`, we pass `@products` (a collection), and Action Policy still infers `ProductPolicy` from it.
:::

## Handling Authorization Failures

When authorization fails, Action Policy raises `ActionPolicy::Unauthorized`. Let's add a global handler in `ApplicationController`:

Open `app/controllers/application_controller.rb` and add:

```ruby ins={2-4}
class ApplicationController < ActionController::Base
  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
```

## Test the Authorization

:::success
Try visiting the products page in the Preview. It should work since our policy allows everyone to view products.
:::

## Adding More Rules

Now let's add rules for the other actions. Update `app/policies/product_policy.rb`:

```ruby ins={12-22}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    # For now, allow everyone
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    true
  end
end
```

## Update the Controller

Add `authorize!` to all actions:

```ruby ins={15,21,27,32}
class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
    authorize! @products
  end

  def show
    authorize! @product
  end

  def new
    @product = Product.new
    authorize! @product
  end

  def create
    @product = Product.new(product_params)
    authorize! @product
    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @product
  end

  def update
    authorize! @product
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @product
    @product.destroy
    redirect_to products_path
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.expect(product: [ :name ])
    end
end
```

## Explicit Rule Specification

Sometimes you want to use a different rule than the action name:

```ruby
# Use update? rule instead of edit?
authorize! @product, to: :update?

# Use a specific policy class
authorize! @product, with: SpecialProductPolicy
```

Great! Now our controller is protected by authorization. Next, let's learn how to check permissions in views.
