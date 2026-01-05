---
type: lesson
title: Testing Policies
focus: /workspace/store/test/policies/product_policy_test.rb
custom:
  shell:
    workdir: "/workspace/store"
---

# Testing Policies

Authorization is critical to your application's security. Policies should have thorough test coverage - this is one area where 100% coverage makes sense!

## Why Test Policies?

1. **Security critical** - Bugs in authorization can lead to data breaches
2. **Easy to test** - Policies are plain Ruby classes, no HTTP needed
3. **Fast** - No database or network in most tests
4. **Documentation** - Tests document expected behavior

## Basic Policy Testing

Policies are regular Ruby classes. Test them like any other class:

```ruby
require "test_helper"

class ProductPolicyTest < ActiveSupport::TestCase
  def setup
    @product = products(:one)
    @admin = users(:admin)
    @user = users(:regular)
  end

  test "anyone can view products" do
    policy = ProductPolicy.new(@product, user: nil)
    assert policy.apply(:index?)
    assert policy.apply(:show?)
  end

  test "logged in users can create products" do
    policy = ProductPolicy.new(@product, user: @user)
    assert policy.apply(:create?)
  end

  test "guests cannot create products" do
    policy = ProductPolicy.new(@product, user: nil)
    refute policy.apply(:create?)
  end

  test "admins can do anything" do
    policy = ProductPolicy.new(@product, user: @admin)
    assert policy.apply(:create?)
    assert policy.apply(:update?)
    assert policy.apply(:destroy?)
  end
end
```

## Create Test Fixtures

First, create fixtures for testing. Open `test/fixtures/users.yml`:

```yaml
admin:
  email_address: admin@example.com
  password_digest: <%= BCrypt::Password.create('secret123') %>

regular:
  email_address: user@example.com
  password_digest: <%= BCrypt::Password.create('secret123') %>
```

Open `test/fixtures/products.yml`:

```yaml
one:
  name: T-Shirt
  published: true

two:
  name: Draft Product
  published: false
```

## Write the Policy Tests

Open `test/policies/product_policy_test.rb`:

```ruby
require "test_helper"

class ProductPolicyTest < ActiveSupport::TestCase
  setup do
    @product = products(:one)
    @admin = users(:admin)
    @user = users(:regular)
  end

  # Index tests
  test "anyone can view product list" do
    policy = ProductPolicy.new(Product.all, user: nil)
    assert policy.apply(:index?)
  end

  # Show tests
  test "anyone can view a product" do
    policy = ProductPolicy.new(@product, user: nil)
    assert policy.apply(:show?)
  end

  # Create tests
  test "guests cannot create products" do
    policy = ProductPolicy.new(Product.new, user: nil)
    refute policy.apply(:create?)
  end

  test "logged in users can create products" do
    policy = ProductPolicy.new(Product.new, user: @user)
    assert policy.apply(:create?)
  end

  # Update tests
  test "guests cannot update products" do
    policy = ProductPolicy.new(@product, user: nil)
    refute policy.apply(:update?)
  end

  test "logged in users can update products" do
    policy = ProductPolicy.new(@product, user: @user)
    assert policy.apply(:update?)
  end

  # Admin tests
  test "admins can do everything" do
    policy = ProductPolicy.new(@product, user: @admin)
    assert policy.apply(:index?)
    assert policy.apply(:show?)
    assert policy.apply(:create?)
    assert policy.apply(:update?)
    assert policy.apply(:destroy?)
  end

  # Alias tests
  test "new is aliased to create" do
    guest_policy = ProductPolicy.new(Product.new, user: nil)
    user_policy = ProductPolicy.new(Product.new, user: @user)

    refute guest_policy.apply(:new?)
    assert user_policy.apply(:new?)
  end

  test "edit is aliased to update" do
    guest_policy = ProductPolicy.new(@product, user: nil)
    user_policy = ProductPolicy.new(@product, user: @user)

    refute guest_policy.apply(:edit?)
    assert user_policy.apply(:edit?)
  end
end
```

## Run the Tests

```bash
$ bin/rails test test/policies/
```

You should see:

```
Running 10 tests in a single process (parallelization threshold is 50)
Run options: --seed 12345

# Running:

..........

Finished in 0.123456s, 81.0001 runs/s, 81.0001 assertions/s.

10 runs, 10 assertions, 0 failures, 0 errors, 0 skips
```

## Testing Scopes

Test scopes separately:

```ruby
test "admins see all products" do
  policy = ProductPolicy.new(nil, user: @admin)
  scope = policy.apply_scope(Product.all, type: :relation)

  assert_includes scope, products(:one)
  assert_includes scope, products(:two)
end

test "regular users only see published products" do
  policy = ProductPolicy.new(nil, user: @user)
  scope = policy.apply_scope(Product.all, type: :relation)

  assert_includes scope, products(:one)      # published
  refute_includes scope, products(:two)      # draft
end

test "guests only see published products" do
  policy = ProductPolicy.new(nil, user: nil)
  scope = policy.apply_scope(Product.all, type: :relation)

  assert_includes scope, products(:one)
  refute_includes scope, products(:two)
end
```

## Testing Failure Reasons

Test that the correct reasons are provided:

```ruby
test "guest create returns not_logged_in reason" do
  policy = ProductPolicy.new(Product.new, user: nil)
  policy.apply(:create?)

  assert_equal :not_logged_in, policy.result.all_details[:reason]
end
```

:::success
Run the tests again to make sure everything passes!
:::

Next, let's learn how to test authorization in controllers.
