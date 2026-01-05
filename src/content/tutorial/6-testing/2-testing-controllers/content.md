---
type: lesson
title: Testing Controllers
focus: /workspace/store/test/controllers/products_controller_test.rb
custom:
  shell:
    workdir: "/workspace/store"
---

# Testing Controllers

While policy tests verify the authorization logic, controller tests verify that authorization is actually applied.

## What to Test

Controller authorization tests should verify:

1. **Authorization is called** - The right policy rule is checked
2. **Scoping is applied** - The right records are returned
3. **Unauthorized access is handled** - Proper response for denied access

## Using Action Policy Test Helpers

Action Policy provides test helpers for Minitest. Add to `test/test_helper.rb`:

```ruby ins={4}
require "action_policy/test_helper"

class ActiveSupport::TestCase
  include ActionPolicy::TestHelper
end
```

## Assert Authorization is Called

Use `assert_authorized_to` to verify authorization:

```ruby
require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include ActionPolicy::TestHelper

  setup do
    @product = products(:one)
    @user = users(:regular)
  end

  test "show authorizes with show?" do
    assert_authorized_to(:show?, @product, with: ProductPolicy) do
      get product_url(@product)
    end
  end

  test "create authorizes with create?" do
    sign_in @user

    assert_authorized_to(:create?, Product, with: ProductPolicy) do
      post products_url, params: { product: { name: "New Product" } }
    end
  end
end
```

## Assert Scoping is Applied

Use `assert_have_authorized_scope` to verify scoping:

```ruby
test "index applies authorized scope" do
  assert_have_authorized_scope(type: :relation, with: ProductPolicy) do
    get products_url
  end
end
```

## Test Unauthorized Access

```ruby
test "guest cannot create product" do
  # Don't sign in - act as guest

  post products_url, params: { product: { name: "New Product" } }

  assert_redirected_to new_session_url
  assert_equal "You must be logged in to perform this action.", flash[:alert]
end

test "guest can view products" do
  get products_url
  assert_response :success
end
```

## Create the Controller Test

Open `test/controllers/products_controller_test.rb`:

```ruby
require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include ActionPolicy::TestHelper

  setup do
    @product = products(:one)
    @user = users(:regular)
    @admin = users(:admin)
  end

  # Helper to sign in
  def sign_in(user)
    post session_url, params: {
      email_address: user.email_address,
      password: "secret123"
    }
  end

  # Index tests
  test "guests can view index" do
    get products_url
    assert_response :success
  end

  test "index applies scope" do
    assert_have_authorized_scope(type: :relation, with: ProductPolicy) do
      get products_url
    end
  end

  # Show tests
  test "guests can view product" do
    get product_url(@product)
    assert_response :success
  end

  test "show authorizes correctly" do
    assert_authorized_to(:show?, @product, with: ProductPolicy) do
      get product_url(@product)
    end
  end

  # Create tests
  test "guests cannot create products" do
    post products_url, params: { product: { name: "Test" } }
    assert_redirected_to new_session_url
  end

  test "logged in users can create products" do
    sign_in @user

    assert_difference("Product.count") do
      post products_url, params: { product: { name: "New Product" } }
    end

    assert_redirected_to product_url(Product.last)
  end

  # Update tests
  test "guests cannot update products" do
    patch product_url(@product), params: { product: { name: "Updated" } }
    assert_redirected_to new_session_url
  end

  test "logged in users can update products" do
    sign_in @user

    patch product_url(@product), params: { product: { name: "Updated" } }
    assert_redirected_to product_url(@product)

    @product.reload
    assert_equal "Updated", @product.name
  end

  # Destroy tests
  test "guests cannot delete products" do
    delete product_url(@product)
    assert_redirected_to new_session_url
  end

  test "logged in users can delete products" do
    sign_in @user

    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  # Admin tests
  test "admins can do everything" do
    sign_in @admin

    # Create
    assert_difference("Product.count") do
      post products_url, params: { product: { name: "Admin Product" } }
    end

    # Update
    patch product_url(@product), params: { product: { name: "Admin Updated" } }
    assert_redirected_to product_url(@product)

    # Destroy
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end
  end
end
```

## Run All Tests

```bash
$ bin/rails test
```

You should see all tests passing:

```
Running tests in parallel...

Finished in 1.234567s, 20.0000 runs/s, 25.0000 assertions/s.

25 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

## Best Practices

### 1. Test Policies Thoroughly
Policy tests are fast and easy - test all edge cases there.

### 2. Controller Tests for Integration
Use controller tests to verify authorization is wired up correctly.

### 3. Use Fixtures Wisely
Create fixtures for different user roles and record states.

### 4. Test Failure Reasons
Verify specific failure messages are returned.

### 5. Don't Duplicate
If policy tests cover the logic, controller tests just verify integration.

:::success
Congratulations! You've completed the Action Policy tutorial!
:::

## What You've Learned

- **Policy basics** - Creating policies with rules
- **Controller integration** - Using `authorize!` and `allowed_to?`
- **verify_authorized** - Ensuring all actions are authorized
- **Advanced features** - Aliases, pre-checks, scoping
- **Failure reasons** - Providing helpful error messages
- **Testing** - Thorough test coverage for security

## Next Steps

- Read the [official documentation](https://actionpolicy.evilmartians.io/)
- Explore [GraphQL integration](https://actionpolicy.evilmartians.io/#/graphql)
- Check out [caching](https://actionpolicy.evilmartians.io/#/caching) for performance
- Learn about [namespaces](https://actionpolicy.evilmartians.io/#/namespaces) for complex apps

Happy authorizing!
