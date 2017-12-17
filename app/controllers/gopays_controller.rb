class GopaysController < ApplicationController
  before_action :set_gopay, only: [:show, :update, :destroy]

  def index
    @gopays = Gopay.all
    json_response(@gopays)
  end

  def show
    json_response(@gopay)
  end

  def update
    @gopay.update(gopay_params)
    head :no_content
  end

  def destroy
    @gopay.destroy
    head :no_content
  end

  private

  def gopay_params
    params.permit(:amount, :user_id, :user_type)
  end

  def set_gopay
    @gopay = Gopay.find(params[:id])
  end
end
