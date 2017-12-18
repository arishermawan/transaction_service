class GopaysController < ApplicationController
  before_action :set_gopay, only: [:add, :reduce, :show, :update, :destroy]

  def index
    @gopays = Gopay.all
    json_response(@gopays)
  end

  def show
    json_response(@gopay)
  end

  def create
    @gopay = Gopay.create!(create_params)
    json_response(@gopay, :created)
  end

  def add
    @gopay.add_credit(update_params)
    json_response(@gopay)
  end

  def reduce
    @gopay.reduce_credit(update_params)
    json_response(@gopay)
  end

  def destroy
    @gopay.destroy
    head :no_content
  end

  private

  def create_params
    params.permit(:credit, :user_id, :user_type)
  end

  def update_params
    params.permit(:credit)
  end

  def set_gopay
    @gopay = Gopay.find(params[:id])
  end
end
