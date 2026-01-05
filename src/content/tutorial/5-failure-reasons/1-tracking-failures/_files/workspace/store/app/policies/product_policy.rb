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
    user.present?
  end

  alias_rule :new?, to: :create?

  def update?
    user.present?
  end

  alias_rule :edit?, :destroy?, to: :update?
end
