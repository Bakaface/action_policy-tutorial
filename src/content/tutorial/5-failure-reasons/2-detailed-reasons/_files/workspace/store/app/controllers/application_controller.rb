class ApplicationController < ActionController::Base
  include Authentication

  authorize :user, through: -> { Current.user }
  verify_authorized

  rescue_from ActionPolicy::Unauthorized do |ex|
    details = ex.result.all_details

    message = case details[:reason]
              when :not_logged_in
                "You must be logged in to perform this action."
              when :not_owner
                "You don't have permission to modify this resource."
              else
                "You are not authorized to perform this action."
              end

    if details[:reason] == :not_logged_in
      redirect_to new_session_path, alert: message
    else
      redirect_to products_path, alert: message
    end
  end
end
