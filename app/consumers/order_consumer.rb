class OrderConsumer < Racecar::Consumer
  subscribes_to "orderServices"

  def process(message)
    array = message.value.split('-->')
    if array.first == "POST"
      order_value = eval(array.second)
      order_params = {}
      order_value.each { |key, value| order_params[key.to_sym] = value }

      find_exist_order = Order.find_by(user_order: order_params[:user_order])
      if find_exist_order.nil?
        new_order = Order.new(order_params)
        new_order.save!
        new_order.request_driver_from_location_services
      end

    elsif array.first == "PATCH"
      order_value = eval(array.second)
      order = Order.find(order_value[:order_id])
      order.update(driver_id: order_value[:driver_id])
      new_order = Order.find(order_value[:order_id])
      puts "<------------------------------------------>#{order.driver_id.nil?}</------------------------------------------>"
      puts "<------------------------------------------>#{order.driver_id}</------------------------------------------>"
      puts "<------------------------------------------></------------------------------------------>"
      puts "<------------------------------------------></------------------------------------------>"
      new_order.send_driver_to_application_services
    end
    sleep(5)

    puts "#{message.value}"
  end
end
