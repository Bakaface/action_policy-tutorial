---
type: lesson
title: Rule Aliases
focus: /workspace/store/app/policies/product_policy.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Rule Aliases

Often, multiple actions require the same authorization logic. Instead of duplicating code, Action Policy provides **rule aliases**.

## The Problem: Duplicated Logic

Look at our current policy:

```ruby
class ProductPolicy < ApplicationPolicy
  def update?
    user.present?
  end

  def edit?
    user.present?  # Same logic!
  end

  def destroy?
    user.present?  # Same again!
  end
end
```

The `edit?` action typically has the same requirements as `update?`. Why write it twice?

## Using alias_rule

Action Policy provides `alias_rule` to solve this:

```ruby ins={6}
class ProductPolicy < ApplicationPolicy
  def update?
    user.present?
  end

  alias_rule :edit?, to: :update?
end
```

Now when `authorize!` checks `edit?`, it actually runs `update?`.

## Update Our Policy

Let's refactor `ProductPolicy` to use aliases:

```ruby ins={16-17}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
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

## Multiple Aliases at Once

Notice this line:

```ruby
alias_rule :edit?, :destroy?, to: :update?
```

You can alias multiple rules to the same target! Both `edit?` and `destroy?` now use the `update?` logic.

## Default Aliases

`ActionPolicy::Base` already includes a common alias:

```ruby
alias_rule :new?, to: :create?
```

This means you don't need to define `new?` separately - it automatically uses `create?`.

## Why Not Ruby's alias?

You might wonder: why not just use Ruby's built-in `alias` or `alias_method`?

```ruby
# Don't do this!
alias edit? update?
```

Action Policy's `alias_rule` is special because:

1. **Resolved at authorization time** - The alias is resolved when `authorize!` is called
2. **Works with caching** - Results are cached correctly
3. **Better for testing** - Tests can check the actual rule being applied
4. **Works with pre-checks** - Pre-checks are applied correctly

## Test the Aliases

Let's verify our aliases work in the console:

```bash
$ bin/rails console
```

```irb
store(dev)> user = User.first
=> #<User id: 1, email_address: "admin@example.com">
store(dev)> product = Product.first
=> #<Product id: 1, name: "T-Shirt">
store(dev)> policy = ProductPolicy.new(product, user: user)
=> #<ProductPolicy:0x...>
store(dev)> policy.apply(:update?)
=> true
store(dev)> policy.apply(:edit?)
=> true
store(dev)> policy.apply(:destroy?)
=> true
```

:::success
All three methods return the same result because they use the same underlying rule!
:::

## Default Rule

You can also set a "catch-all" default rule:

```ruby
class ProductPolicy < ApplicationPolicy
  default_rule :manage?

  def manage?
    user.admin?
  end
end
```

Now any undefined rule (like `archive?`) will fall back to `manage?`.

Next, let's learn about pre-checks for adding admin bypasses!
