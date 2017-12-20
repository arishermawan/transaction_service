class OrderConsumer < Racecar::Consumer
  subscribes_to "orderServices"

  def process(message)
    puts "-------------#{message.value}--------------------"
    array = message.value.split('-->')
    if array.first == "POST"
      values = eval(array.second)
      order = {}
      values.each { |key, value| order[key.to_sym] = value }

      find_exist_order = Order.find_by(user_order: order[:user_order])
      if find_exist_order.nil?
        new_order = Order.new(order)
        new_order.save!
        new_order.request_driver_from_location_services
      end

    elsif array.first == "PATCH"
      values = eval(array.second)
      order = Order.find(values[:order_id])
      status = values[:driver_id].to_s.empty? ? 3 : 1
      order.update(driver_id: values[:driver_id], status: status)
      new_order = Order.find(values[:order_id])
      new_order.send_driver_to_application_services

    elsif array.first == "UPDATE"
      values = eval(array.second)
      order = Order.find_by(user_order: values[:user_order])
      order.update(status: values[:status])
    end
    sleep(5)

  end
end
