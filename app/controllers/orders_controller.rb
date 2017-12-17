class OrdersController < ApplicationController
  # skip_before_action :authorize_request, only: [:create]
  before_action :set_order, only: [:show, :update, :destroy]

  def index
    @orders = Order.all
    json_response(@orders)
  end

  def create
    @order=Order.new(order_params)
    @order.customer_id = @order.customer_id.to_i
    @order = Order.create!(order_params)
    json_response(@order, :created)
    # @auth_token = AuthenticateUser.new(@order.email, @order.password).call
    # response = { message: Message.account_created, auth_token: @auth_token }
    # json_response(response, :created)

  end

  def show
    json_response(@order)
  end

  def update
    @order.update(order_params)
    head :no_content
  end

  def destroy
    @order.destroy
    head :no_content
  end

  private

  def order_params
    params.permit(:pickup, :destination, :distance, :total, :driver_id, :customer_id, :service, :payment)
  end

  def set_order
    @order = Order.find(params[:id])
  end
end
