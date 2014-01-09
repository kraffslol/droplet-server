class FileController < ApplicationController
  def view
    file = Upload.where(slug: params[:id]).last
    if(file)
      @file = file
    else
      render :nothing => true, :Status => 404
    end
  end

  def redirect
    file = Upload.where(slug: params[:id]).last
    if(file)
      redirect_to "http://f.droplet.pw/" + file.filename
    else
      render :nothing => true, :status => 404
    end
  end
end
