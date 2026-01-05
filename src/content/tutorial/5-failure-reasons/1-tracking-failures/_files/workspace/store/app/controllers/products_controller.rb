class ProductsController < ApplicationController
  allow_unauthenticated_access only: [:index, :show]
  before_action :set_product, only: %i[ show edit update destroy ]

  def index
    @products = authorized_scope(Product.all)
    authorize! @products
  end

  def show
    authorize! @product
  end

  def new
    @product = Product.new
    authorize! @product
  end

  def create
    @product = Product.new(product_params)
    authorize! @product
    if @product.save
      redirect_to @product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize! @product
  end

  def update
    authorize! @product
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @product
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
