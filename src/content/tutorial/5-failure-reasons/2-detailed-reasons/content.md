---
type: lesson
title: Detailed Reasons
focus: /workspace/store/app/policies/product_policy.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Detailed Reasons

Sometimes you need more than just the rule name - you need specific details about *why* authorization failed.

## Adding Details to Reasons

Use the `details` hash to provide additional context:

```ruby
class ProductPolicy < ApplicationPolicy
  def update?
    deny!(:not_owner) unless owner?

    if record.archived?
      details[:archived_at] = record.archived_at
      deny!(:archived)
    end

    true
  end
end
```

Access the details:

```ruby
ex.result.reasons.details
#=> { product: [{ update?: { archived_at: "2024-01-01" } }] }
```

## Real-World Example

Let's update our policy with detailed failure tracking:

```ruby ins={10-20}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user&.admin?
      relation
    else
      relation.where(published: true)
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    unless user.present?
      details[:reason] = :not_logged_in
      return deny!
    end
    true
  end

  alias_rule :new?, to: :create?

  def update?
    unless user.present?
      details[:reason] = :not_logged_in
      return deny!
    end
    true
  end

  alias_rule :edit?, :destroy?, to: :update?
end
```

## Using all_details

The `all_details` method merges all details into a single hash:

```ruby
rescue_from ActionPolicy::Unauthorized do |ex|
  details = ex.result.all_details

  if details[:reason] == :not_logged_in
    redirect_to new_session_path, alert: "Please log in first."
  elsif details[:reason] == :not_owner
    redirect_to products_path, alert: "You don't own this product."
  else
    redirect_to root_path, alert: "Access denied."
  end
end
```

## I18n Integration

Combine details with I18n for localized messages:

Create `config/locales/action_policy.en.yml`:

```yaml
en:
  action_policy:
    policy:
      product:
        create?: "You must log in to create products"
        update?: "You cannot edit this product"
        destroy?: "Only admins can delete products"
```

Use `full_messages`:

```ruby
rescue_from ActionPolicy::Unauthorized do |ex|
  messages = ex.result.reasons.full_messages

  if messages.any?
    redirect_to products_path, alert: messages.join(". ")
  else
    redirect_to products_path, alert: "Access denied."
  end
end
```

## Details with Interpolation

You can use details for I18n interpolation:

```ruby
# Policy
def update?
  details[:product_name] = record.name
  deny!(:not_owner) unless owner?
  true
end

# Locale file
en:
  action_policy:
    policy:
      product:
        not_owner: "You cannot edit '%{product_name}'"

# Result
ex.result.reasons.full_messages
#=> ["You cannot edit 'T-Shirt'"]
```

## Practical Pattern: Conditional Responses

Use details to drive different responses:

```ruby
rescue_from ActionPolicy::Unauthorized do |ex|
  details = ex.result.all_details

  case details[:reason]
  when :not_logged_in
    store_location_and_redirect_to_login
  when :subscription_required
    redirect_to pricing_path, alert: "Upgrade your plan to access this feature"
  when :rate_limited
    render json: { error: "Too many requests" }, status: :too_many_requests
  else
    head :forbidden
  end
end
```

## Test Detailed Reasons

```bash
$ bin/rails console
```

```irb
store(dev)> policy = ProductPolicy.new(Product.first, user: nil)
=> #<ProductPolicy:0x...>
store(dev)> policy.apply(:create?)
=> false
store(dev)> policy.result.all_details
=> {:reason=>:not_logged_in}
```

:::success
Detailed reasons help you provide specific, actionable feedback to users!
:::

Now let's move on to testing - ensuring our policies work correctly.
