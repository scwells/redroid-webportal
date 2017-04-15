class ImagesController < ApplicationController
skip_before_action :verify_authenticity_token
before_action :verify_file_param

# PUT /images/*img <---- param[:img]
def upload
  if File.exists?(file_path = "/home/redroid/motion_detection_images/#{params[:img]}.jpg")
    send_403_forbidden
  else
    File.open(file_path, 'wb') { |file| file.write(request.raw_post)}
    send_200_ok
  end
end

# GET /images
def fetch
  if params[:img] && File.exists?(file_path = "/home/redroid/motion_detection_images/#{params[:img]}.jpg")
    send_file file_path
  else
    send_404_not_found
  end
end

def verify_file_param
  if params[:img] && params[:img] !~ /\A(\w|\d)+\z/
    send_403_forbidden
  end
end

def error_404
    render layout: false
end

private
  def send_403_forbidden
    render nothing: true, status: 403, content_type: 'text/html'
  end

  def send_404_not_found
    render nothing: true, status: 404, content_type: 'text/html'
  end

  def send_200_ok
    render nothing: true, status: 200, content_type: 'text/html'
  end
end
