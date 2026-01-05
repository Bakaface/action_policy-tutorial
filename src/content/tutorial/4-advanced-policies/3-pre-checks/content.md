---
type: lesson
title: Pre-Checks
focus: /workspace/store/app/policies/application_policy.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Pre-Checks

Pre-checks allow you to run common authorization logic **before** every rule. The most common use case: allowing admins to bypass all authorization.

## The Problem

Without pre-checks, you'd repeat admin logic in every rule:

```ruby
class ProductPolicy < ApplicationPolicy
  def update?
    user.admin? || user.id == record.user_id  # Admin check repeated
  end

  def destroy?
    user.admin? || user.id == record.user_id  # Same check again!
  end

  def archive?
    user.admin? || some_other_condition  # And again...
  end
end
```

## Using pre_check

Pre-checks run before every policy rule:

```ruby
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins

  private

  def allow_admins
    allow! if user&.admin?
  end
end
```

Now **every** policy that inherits from `ApplicationPolicy` will automatically allow admins!

## How Pre-Checks Work

A pre-check can:

1. **Allow** - Call `allow!` to immediately authorize
2. **Deny** - Call `deny!` to immediately reject
3. **Continue** - Return anything else to proceed to the actual rule

```ruby
def allow_admins
  # If admin, stop here and allow
  allow! if user&.admin?

  # If not admin, this pre-check does nothing,
  # and the actual rule will run
end
```

## Update ApplicationPolicy

Open `app/policies/application_policy.rb` and add the admin pre-check:

```ruby ins={2,6-8}
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins

  private

  def allow_admins
    allow! if user&.admin?
  end
end
```

## Update User Model

We need an `admin?` method on User. Open `app/models/user.rb`:

```ruby ins={6-8}
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def admin?
    email_address.include?("admin")
  end
end
```

For this tutorial, we consider any user with "admin" in their email as an admin.

## Test Admin Access

Log in with `admin@example.com` / `secret123` and try editing/deleting products:

:::success
Admins can do everything! The pre-check runs before each rule and allows admins automatically.
:::

Now log in with `user@example.com` / `secret123`:

:::info
Regular users are still subject to the normal policy rules.
:::

## Selective Pre-Checks

You can limit pre-checks to specific rules:

```ruby
class ProductPolicy < ApplicationPolicy
  # Only apply to update and destroy
  pre_check :allow_admins, only: [:update?, :destroy?]

  # Apply to everything except index
  pre_check :require_verified_email, except: [:index?]
end
```

## Skip Pre-Checks

Child policies can skip inherited pre-checks:

```ruby
class SensitiveDataPolicy < ApplicationPolicy
  # Even admins shouldn't bypass this!
  skip_pre_check :allow_admins, only: [:destroy?]

  def destroy?
    # Only super-admins can destroy sensitive data
    user.super_admin?
  end
end
```

## Multiple Pre-Checks

You can have multiple pre-checks that run in order:

```ruby
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins
  pre_check :deny_banned_users
  pre_check :require_verified_email

  private

  def allow_admins
    allow! if user&.admin?
  end

  def deny_banned_users
    deny! if user&.banned?
  end

  def require_verified_email
    deny! unless user&.email_verified?
  end
end
```

The first pre-check to call `allow!` or `deny!` wins. If none do, the actual rule runs.

Next, let's learn about scoping to filter records based on user permissions!
