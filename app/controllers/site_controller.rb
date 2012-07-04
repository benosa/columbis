class SiteController < ApplicationController
  def index
  end

  def online
    render :text => 'online'
  end
end
