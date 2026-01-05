---
type: lesson
title: Installing Action Policy
focus: /workspace/store/app/policies/application_policy.rb
custom:
  shell:
    workdir: "/workspace/store"
---

# Installing Action Policy

Action Policy is already included in our application's dependencies. Now we need to set up the base policy class.

## The Installation Generator

In a real Rails project, you would run:

```bash
$ bin/rails generate action_policy:install
```

This creates `app/policies/application_policy.rb` - the base class that all your policies will inherit from.

:::info
For this tutorial, we've pre-created the file so you can see it in the editor immediately.
:::

## Examine the ApplicationPolicy

Open `app/policies/application_policy.rb` in the editor:

```ruby
# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  private

  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.user_id == user.id
  #  end
end
```

## Key Points

### 1. Inherits from ActionPolicy::Base

`ApplicationPolicy` inherits from `ActionPolicy::Base`, which provides all the core functionality:
- Policy rule definitions
- Authorization context (the `user` object)
- Pre-checks, aliases, and other features

### 2. Central Configuration

This class is the perfect place to:
- Add shared authorization contexts (like `account` or `organization`)
- Define helper methods used across multiple policies
- Configure default behaviors

### 3. Convention

All your resource policies will inherit from this class:

```ruby
class ProductPolicy < ApplicationPolicy
  # Policy rules here
end

class UserPolicy < ApplicationPolicy
  # Policy rules here
end
```

## What's Next?

Now that we have the base policy class, let's create our first actual policy for the Product model!
