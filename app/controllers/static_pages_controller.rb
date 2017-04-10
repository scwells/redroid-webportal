class StaticPagesController < ApplicationController
  def home
  end
  def index
    render :layout => 'layouts/_static_pages'
  end  
end
