class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: ENV['USER_LOGIN'], password: ENV['USER_PASSWORD']
end
