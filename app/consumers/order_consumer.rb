class OrderConsumer < Racecar::Consumer
  subscribes_to "order"

  def process(message)
    puts "Received message: #{message.value}"
  end
end
