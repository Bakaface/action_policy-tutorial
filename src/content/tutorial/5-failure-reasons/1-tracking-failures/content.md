---
type: lesson
title: Tracking Failures
focus: /workspace/store/app/controllers/application_controller.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Tracking Failures

When authorization fails, a generic "not authorized" message isn't very helpful. Action Policy tracks **failure reasons** so you can provide specific, actionable feedback.

## The Problem with Generic Messages

```ruby
rescue_from ActionPolicy::Unauthorized do |ex|
  redirect_to root_path, alert: "You are not authorized."
end
```

This tells users nothing about *why* they were denied. Was it because:
- They're not logged in?
- They don't own the resource?
- The resource is archived?

## Accessing Failure Reasons

When `ActionPolicy::Unauthorized` is raised, it includes a `result` object with reasons:

```ruby
rescue_from ActionPolicy::Unauthorized do |ex|
  # The policy that denied access
  ex.policy  #=> ProductPolicy

  # The rule that failed
  ex.rule    #=> :update?

  # The result object
  ex.result  #=> ActionPolicy::Result

  # Failure reasons
  ex.result.reasons.to_h  #=> { product: [:update?] }
end
```

## Update the Error Handler

Open `app/controllers/application_controller.rb` and update the error handler:

```ruby ins={5-15}
class ApplicationController < ActionController::Base
  include Authentication

  authorize :user, through: -> { Current.user }
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |ex|
    message = case ex.rule
              when :create?, :new?
                "You must be logged in to create products."
              when :update?, :edit?
                "You can only edit your own products."
              when :destroy?
                "Only administrators can delete products."
              else
                "You are not authorized to perform this action."
              end

    redirect_to products_path, alert: message
  end
end
```

Now users get specific feedback!

## Using allow! and deny! with Reasons

You can provide reasons when denying access:

```ruby
class ProductPolicy < ApplicationPolicy
  def update?
    deny!(:not_owner) unless owner?
    deny!(:archived) if record.archived?
    true
  end

  private

  def owner?
    user.id == record.user_id
  end
end
```

Access the reason:

```ruby
ex.result.reasons.to_h  #=> { product: [:not_owner] }
# or
ex.result.reasons.to_h  #=> { product: [:archived] }
```

## Nested Policy Reasons

When policies call other policies, reasons are tracked through the chain:

```ruby
class CommentPolicy < ApplicationPolicy
  def update?
    # Check if user can update the parent post
    allowed_to?(:update?, record.post)
  end
end
```

If the post policy denies access:

```ruby
ex.result.reasons.to_h  #=> { post: [:update?] }
```

## The full_messages Helper

For human-readable messages, use `full_messages` with I18n:

```ruby
# config/locales/en.yml
en:
  action_policy:
    policy:
      product:
        update?: "You cannot edit this product"
        destroy?: "You cannot delete this product"

# In controller
ex.result.reasons.full_messages  #=> ["You cannot edit this product"]
```

## Test Failure Reasons

Let's see failure reasons in action:

1. Log out (or use an incognito window)
2. Try to create a new product
3. You should see: "You must be logged in to create products."

```bash
$ bin/rails console
```

```irb
store(dev)> policy = ProductPolicy.new(Product.first, user: nil)
=> #<ProductPolicy:0x...>
store(dev)> result = policy.apply(:create?)
=> false
store(dev)> policy.result.reasons.to_h
=> {}  # No nested reasons in this simple case
```

:::info
Failure reasons are most useful when you have complex policies with multiple conditions or nested policy calls.
:::

Next, let's learn how to add detailed context to failure reasons!
