---
type: lesson
title: Your First Policy
focus: /workspace/store/app/policies/product_policy.rb
custom:
  shell:
    workdir: "/workspace/store"
---

# Your First Policy

Now let's create a policy for our Product model. We'll start simple and build up from there.

## Generate a Policy

Run the policy generator:

```bash
$ bin/rails generate action_policy:policy Product
```

You should see:

```bash
      create  app/policies/product_policy.rb
      create  test/policies/product_policy_test.rb
```

## Examine the Generated Policy

Open `app/policies/product_policy.rb`:

```ruby
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  # See https://actionpolicy.evilmartians.io/#/writing_policies
  #
  # def index?
  #   true
  # end
  #
  # def update?
  #   # here we can access our context and record
  #   user.admin? || (user.id == record.user_id)
  # end
end
```

The generator creates a skeleton with helpful comments showing example rule methods.

## Write Your First Rules

Let's add some real authorization rules. Replace the contents with:

```ruby ins={4-6,8-10}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end
end
```

## Understanding Policy Rules

### Rule Naming Convention

Policy rules are **predicate methods** (methods ending with `?`) that return `true` or `false`:

- `index?` - Can the user list products?
- `show?` - Can the user view a product?
- `create?` - Can the user create a product?
- `update?` - Can the user update a product?
- `destroy?` - Can the user delete a product?

### The Rule Context

Inside a policy rule, you have access to:

- **`user`** - The current user (from `current_user` in your controller)
- **`record`** - The object being authorized (the product in this case)

### Try It in the Console

Let's test our policy in the Rails console:

```bash
$ bin/rails console
```

```irb
store(dev)> policy = ProductPolicy.new(Product.first, user: nil)
=> #<ProductPolicy:0x...>
store(dev)> policy.index?
=> true
store(dev)> policy.show?
=> true
```

Our policy allows anyone to view products. Now we need to connect it to our controller!

:::info
We passed `user: nil` because we don't have authentication set up yet. In a real app, this would be `current_user`.
:::

## What's Next?

In the next section, we'll learn how to use `authorize!` in our controller to enforce these policy rules.
