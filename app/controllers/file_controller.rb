class FileController < ApplicationController
  def view
    render text: "hi"
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
