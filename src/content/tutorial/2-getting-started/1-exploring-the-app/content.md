---
type: lesson
title: Exploring the Store App
focus: /workspace/store/app/controllers/products_controller.rb
previews:
  - 3000
mainCommand: ['node scripts/rails.js server', 'Starting Rails server']
custom:
  shell:
    workdir: "/workspace/store"
---

# Exploring the Store App

Before we add authorization, let's explore the Rails application we'll be working with throughout this tutorial.

## The Products Controller

Open `app/controllers/products_controller.rb` in the editor to see a standard Rails CRUD controller:

```ruby
class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path
  end

  private
    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.expect(product: [ :name ])
    end
end
```

## Try It Out

:::success
Click on the **Preview** tab to see the application running. You can:
- View all products at the index page
- Click on a product to see its details
- Create new products using the "New Product" link
- Edit and delete existing products
:::

## The Problem

Right now, **anyone can do anything**:
- No authentication required
- No authorization checks
- Any visitor can create, edit, or delete products

In a real application, you'd want to control who can perform each action. That's what we'll add with Action Policy!

## What We'll Build

By the end of this tutorial, we'll have policies that:

1. Allow anyone to view products (`index` and `show`)
2. Require authentication to create products (`new` and `create`)
3. Allow only product owners or admins to edit products (`edit` and `update`)
4. Allow only admins to delete products (`destroy`)

Let's start by installing Action Policy!
