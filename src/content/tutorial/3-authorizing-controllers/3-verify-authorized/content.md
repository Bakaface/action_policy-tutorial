---
type: lesson
title: verify_authorized
focus: /workspace/store/app/controllers/application_controller.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# verify_authorized

It's easy to forget to add `authorize!` to a controller action. Action Policy provides a safety net: `verify_authorized`.

## The Problem

Imagine you add a new action and forget to authorize it:

```ruby
def special_action
  @products = Product.where(special: true)
  # Oops! Forgot authorize!
end
```

This action is now unprotected. Anyone can access it!

## The Solution: verify_authorized

Add `verify_authorized` to your `ApplicationController`:

```ruby ins={2}
class ApplicationController < ActionController::Base
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
```

Now, if any action completes without calling `authorize!`, Rails raises `ActionPolicy::UnauthorizedAction`.

## How It Works

After every action, Action Policy checks whether `authorize!` was called:

- **If called**: Action proceeds normally
- **If not called**: Raises `ActionPolicy::UnauthorizedAction`

This ensures you never accidentally ship an unprotected action.

## Skipping Verification

Some actions legitimately don't need authorization (like public landing pages). You can skip the check:

```ruby
class PagesController < ApplicationController
  skip_verify_authorized only: [:home, :about]

  def home
    # No authorization needed for public pages
  end

  def about
  end
end
```

Or skip dynamically within an action:

```ruby
def public_action
  skip_verify_authorized!
  # Action logic...
end
```

## Filtering by Action Type

You can limit verification to specific actions:

```ruby
class ApplicationController < ActionController::Base
  # Only verify write operations
  verify_authorized except: [:index, :show]
end
```

## Try It Out

Let's test this safety net:

1. First, make sure `verify_authorized` is in your `ApplicationController`

2. Let's temporarily remove authorization from the `index` action in `ProductsController`:

```ruby del={6}
def index
  @products = Product.all
  authorize! @products
end
```

3. Try visiting the products page in the Preview

You should see an error because we forgot to authorize!

4. Add the `authorize!` call back:

```ruby ins={3}
def index
  @products = Product.all
  authorize! @products
end
```

:::success
The page should work again. `verify_authorized` ensures we never forget authorization!
:::

## Best Practice

Always add `verify_authorized` to your `ApplicationController`. It's a simple safeguard that prevents security holes.

```ruby
class ApplicationController < ActionController::Base
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |ex|
    redirect_to root_path, alert: "You are not authorized."
  end

  rescue_from ActionPolicy::UnauthorizedAction do |ex|
    # This should never happen in production!
    # It means a developer forgot to add authorization.
    raise ex if Rails.env.development?
    redirect_to root_path, alert: "An error occurred."
  end
end
```

Now we have a solid foundation for authorization. In the next section, we'll explore advanced policy features!
