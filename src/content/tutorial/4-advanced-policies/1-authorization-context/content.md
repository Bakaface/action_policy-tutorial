---
type: lesson
title: Authorization Context
focus: /workspace/store/app/policies/application_policy.rb
custom:
  shell:
    workdir: "/workspace/store"
---

# Authorization Context

So far, our policies have been simple because we haven't had real users. Let's add authentication and learn about **authorization context**.

## What is Authorization Context?

Authorization context is the information available to your policy when making authorization decisions. By default, Action Policy provides:

- **`user`** - The current user (from `current_user`)
- **`record`** - The object being authorized

You can add additional context like `account`, `organization`, or `tenant`.

## Setting Up Authentication

First, let's generate Rails authentication:

```bash
$ bin/rails generate authentication
```

This creates:
- `User` model with email and password
- `Session` model for tracking sessions
- `SessionsController` for login/logout
- `Authentication` concern for controllers

Now migrate the database:

```bash
$ bin/rails db:migrate
```

## Understanding the Generated Code

Open `app/controllers/concerns/authentication.rb`:

```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  # ...

  private
    def authenticated?
      Current.session.present?
    end

    def require_authentication
      resume_session || request_authentication
    end
end
```

The key method here is `Current.session` which gives us access to the current user.

## Configuring Action Policy Context

Open `app/controllers/application_controller.rb` and update it:

```ruby ins={4-5}
class ApplicationController < ActionController::Base
  include Authentication

  # Action Policy will use Current.user as the authorization context
  authorize :user, through: -> { Current.user }

  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
```

The `authorize :user, through:` line tells Action Policy how to get the current user.

## Create a Test User

Let's create a user to test with. Run the Rails console:

```bash
$ bin/rails console
```

```irb
store(dev)> User.create!(email_address: "admin@example.com", password: "secret123")
=> #<User id: 1, email_address: "admin@example.com", ...>
```

## Update the Policy

Now let's update our `ProductPolicy` to use the user:

```ruby ins={4-6,12-14}
# frozen_string_literal: true

class ProductPolicy < ApplicationPolicy
  def index?
    true  # Anyone can view the list
  end

  def show?
    true  # Anyone can view a product
  end

  def create?
    user.present?  # Only logged-in users can create
  end

  def update?
    user.present?  # Only logged-in users can update
  end

  def destroy?
    user.present?  # Only logged-in users can delete
  end
end
```

## Skip Authentication for Public Pages

We need to allow viewing products without being logged in. Update `ProductsController`:

```ruby ins={2}
class ProductsController < ApplicationController
  skip_before_action :require_authentication, only: [:index, :show]
  before_action :set_product, only: %i[ show edit update destroy ]

  # ... rest of controller
end
```

## Handling Missing User

When a user isn't logged in, `Current.user` is `nil`. Our policy needs to handle this:

```ruby
def create?
  user.present?  # Returns false if user is nil
end
```

:::info
In the policy, `user` refers to the authorization context we configured with `authorize :user, through:`.
:::

## Test It Out

Try these scenarios:

1. Visit the products page as a guest - you can view products
2. Try to create a product - you'll be redirected to login
3. Log in and try again - now you can create products!

Next, we'll learn about rule aliases to reduce duplication in our policies.
