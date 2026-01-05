class ApplicationController < ActionController::Base
  rescue_from ActionPolicy::Unauthorized do |exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
