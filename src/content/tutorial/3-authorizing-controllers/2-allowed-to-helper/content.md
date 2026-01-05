---
type: lesson
title: Using allowed_to? in Views
focus: /workspace/store/app/views/products/index.html.erb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Using allowed_to? in Views

While `authorize!` enforces authorization, sometimes you need to **check** permissions without raising an exception. This is especially useful in views to show or hide UI elements.

## The allowed_to? Helper

`allowed_to?` returns `true` or `false` based on the policy check:

```ruby
# Returns true if the user can edit the product
allowed_to?(:edit?, @product)

# Returns false if they can't
allowed_to?(:destroy?, @product)
```

## Conditional UI Elements

Open `app/views/products/index.html.erb` and let's add conditional links:

```erb ins={9-11,14-16}
<h1>Products</h1>

<div id="products">
  <% @products.each do |product| %>
    <div style="padding: 10px; margin: 5px 0; border: 1px solid #ccc;">
      <strong><%= link_to product.name, product_path(product) %></strong>

      <div style="margin-top: 5px;">
        <% if allowed_to?(:edit?, product) %>
          <%= link_to "Edit", edit_product_path(product) %>
        <% end %>

        <% if allowed_to?(:destroy?, product) %>
          <%= button_to "Delete", product_path(product), method: :delete,
            data: { turbo_confirm: "Are you sure?" } %>
        <% end %>
      </div>
    </div>
  <% end %>
</div>

<%= link_to "New Product", new_product_path if allowed_to?(:new?, Product.new) %>
```

## Why This Matters

Consider these scenarios:

### Without allowed_to?
- User sees "Edit" button
- User clicks button
- Authorization fails
- User gets error message

### With allowed_to?
- Authorization is checked
- User doesn't see the button at all
- Better user experience!

## Check Permissions in the Show View

Open `app/views/products/show.html.erb`:

```erb ins={5-12}
<h1><%= @product.name %></h1>

<p><%= @product.name %></p>

<div style="margin-top: 20px;">
  <% if allowed_to?(:edit?, @product) %>
    <%= link_to "Edit", edit_product_path(@product) %>
  <% end %>

  <% if allowed_to?(:destroy?, @product) %>
    <%= button_to "Delete", product_path(@product), method: :delete %>
  <% end %>
</div>

<%= link_to "Back to products", products_path %>
```

## Using allowed_to? in Controllers

You can also use `allowed_to?` in controllers for conditional logic:

```ruby
def index
  @products = Product.all

  # Add admin-only statistics
  if allowed_to?(:manage?, Product)
    @statistics = calculate_statistics
  end
end
```

## Explicit Policy Specification

Just like `authorize!`, you can specify the policy class:

```erb
<% if allowed_to?(:special_action?, @product, with: SpecialProductPolicy) %>
  <%= link_to "Special Action", special_path(@product) %>
<% end %>
```

:::success
Refresh the Preview to see the conditional links. Since all our policy rules currently return `true`, you'll see all the buttons.
:::

Next, let's learn about `verify_authorized` to ensure we never forget to add authorization!
