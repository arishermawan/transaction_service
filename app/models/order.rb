class Order < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :driver, optional: true

  before_update  :subtract_gopay, if: :driver_found
  before_update  :add_gopay, if: :order_complete
  # after_create :request_driver_from_location_services
  # after_update :send_driver_to_application_services
  enum status: {
    "searching driver" => 0,
    "driver found" => 1,
    "complete" => 2,
    "cancel" => 3
  }

  enum service: {
    "goride" => 0,
    "gocar" => 1
  }

  enum payment: {
    "cash" => 0,
    "gopay" => 1
  }

  validates :payment, inclusion: payments.keys
  validates :service, inclusion: services.keys
  validates :pickup, :destination, presence:true


  def request_driver_from_location_services
    require 'kafka'
    kafka = Kafka.new( seed_brokers: ['localhost:9092'], client_id: 'transaction-service')

    find_driver = Hash.new
    find_driver[:order_id] = id
    find_driver[:pickup] = pickup
    find_driver[:service] = service

    kafka.deliver_message("POST-->#{find_driver.to_json}", topic: 'locationServices')
  end

  def send_driver_to_application_services
    require 'kafka'
    kafka = Kafka.new( seed_brokers: ['localhost:9092'], client_id: 'transaction-service')
    driver = ""
    driver_id.nil? ? driver = "" : driver = driver_id

    found_driver = Hash.new
    found_driver[:order_id] = user_order
    found_driver[:driver_id] = driver

    kafka.deliver_message("PATCH-->#{found_driver.to_json}", topic: 'applicationServices')
  end

  def driver_found
    changed.include?("status") && status == "driver found"
  end

  def order_complete
    changed.include?("status") && status == "complete"
  end

  def subtract_gopay
    if payment == 'gopay'
      gopay = Gopay.find_by(user_id: customer_id, user_type: 'Customer')
      gopay.reduce_credit(credit: total)
    end
  end

  def add_gopay
    if payment == 'gopay'
      gopay = Gopay.find_by(user_id: driver_id, user_type: 'Driver')
      if gopay.nil?
        Gopay.new.add_record(total, driver_id, 'Driver')
      else
        gopay.add_credit(credit: total)
      end
    end
  end

end
