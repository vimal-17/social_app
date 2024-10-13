class ApplicationController < ActionController::Base

  def health
    return render json: { status: :ok }, status: :ok
  end

end
