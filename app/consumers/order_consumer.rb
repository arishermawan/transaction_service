class OrderConsumer < Racecar::Consumer
  subscribes_to "orderServices"

  def process(message)
    array = message.value.split('-->')
    order_value = eval(array.second)
    order_params = {}
    order_value.each { |key, value| order_params[key.to_sym] = value }

    find_exist_order = Order.find_by(user_order: order_params[:user_order])
    if find_exist_order.nil?
      new_order = Order.new(order_params)
      new_order.save!
    end

    sleep(5)
  end
end
