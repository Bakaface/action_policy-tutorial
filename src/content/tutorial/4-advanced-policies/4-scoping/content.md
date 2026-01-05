---
type: lesson
title: Scoping
focus: /workspace/store/app/policies/product_policy.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Scoping

So far, we've authorized individual actions. But what about filtering records? **Scoping** lets you define which records a user can see or act upon.

## The Problem

Consider this common pattern in controllers:

```ruby
def index
  @products =
    if current_user.admin?
      Product.all
    else
      Product.where(published: true)
    end
end
```

This works, but:
- The logic is in the controller, not the policy
- It's easy to forget to apply it consistently
- Testing requires full controller setup

## Using authorized_scope

Action Policy provides `authorized_scope` to move this logic to policies:

```ruby
# In controller
def index
  @products = authorized_scope(Product.all)
end

# In policy
relation_scope do |relation|
  if user&.admin?
    relation
  else
    relation.where(published: true)
  end
end
```

## Add Scoping to ProductPolicy

Let's add a scope that shows all products to admins, but only some to regular users.

First, add a `published` column to products:

```bash
$ bin/rails generate migration AddPublishedToProducts published:boolean
```

```bash
$ bin/rails db:migrate
```

Now update `app/policies/product_policy.rb`:

```ruby ins={4-10}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user&.admin?
      relation  # Admins see all
    else
      relation.where(published: true)  # Others see only published
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  alias_rule :new?, to: :create?

  def update?
    user.present?
  end

  alias_rule :edit?, :destroy?, to: :update?
end
```

## Update the Controller

Open `app/controllers/products_controller.rb` and use `authorized_scope`:

```ruby ins={6}
def index
  @products = authorized_scope(Product.all)
  authorize! @products
end
```

Wait - we're calling both `authorized_scope` AND `authorize!`? Yes! They do different things:

- `authorized_scope` - Filters the records
- `authorize!` - Checks if the user can perform the action

## Named Scopes

You can define multiple scopes for different purposes:

```ruby
class ProductPolicy < ApplicationPolicy
  # Default scope
  relation_scope do |relation|
    relation.where(published: true)
  end

  # Named scope for "own" products
  relation_scope :own do |relation|
    relation.where(user_id: user.id)
  end

  # Named scope for editing
  relation_scope :editable do |relation|
    if user.admin?
      relation
    else
      relation.where(user_id: user.id)
    end
  end
end
```

Use named scopes like this:

```ruby
# Default scope
@products = authorized_scope(Product.all)

# Named scope
@my_products = authorized_scope(Product.all, as: :own)
@editable = authorized_scope(Product.all, as: :editable)
```

## Scope Options

You can pass options to scopes:

```ruby
relation_scope do |relation, with_drafts: false|
  scope = relation.where(published: true)
  scope = scope.or(relation.where(draft: true)) if with_drafts
  scope
end

# Use it
authorized_scope(Product.all, scope_options: { with_drafts: true })
```

## Testing Scopes

Scopes are easy to test in isolation:

```bash
$ bin/rails console
```

```irb
store(dev)> admin = User.find_by(email_address: "admin@example.com")
store(dev)> policy = ProductPolicy.new(nil, user: admin)
store(dev)> policy.apply_scope(Product.all, type: :relation)
=> #<Product::ActiveRecord_Relation ...>  # All products

store(dev)> regular = User.find_by(email_address: "user@example.com")
store(dev)> policy = ProductPolicy.new(nil, user: regular)
store(dev)> policy.apply_scope(Product.all, type: :relation)
=> #<Product::ActiveRecord_Relation ...>  # Only published
```

## Params Scoping

Action Policy also provides scoping for Strong Parameters:

```ruby
class ProductPolicy < ApplicationPolicy
  params_filter do |params|
    if user.admin?
      params.permit(:name, :price, :published, :featured)
    else
      params.permit(:name, :price)  # Regular users can't set published/featured
    end
  end
end
```

```ruby
# In controller
def product_params
  authorized_scope(params.require(:product))
end
```

:::success
Scoping keeps your authorization logic organized and testable!
:::

Next, we'll learn about failure reasons - understanding why authorization failed.
