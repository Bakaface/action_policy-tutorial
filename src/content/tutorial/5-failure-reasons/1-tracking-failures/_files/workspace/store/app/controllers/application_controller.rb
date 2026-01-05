class ApplicationController < ActionController::Base
  include Authentication

  authorize :user, through: -> { Current.user }

  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
