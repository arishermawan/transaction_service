class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :driver, optional: true

  enum service: {
    "goride" => 0,
    "gocar" => 1
  }

  enum payment: {
    "cash" => 0,
    "gopay" => 1
  }

  # validates_with GopayValidator
  validates :payment, inclusion: payments.keys
  validates :service, inclusion: services.keys
  validates :pickup, :destination, presence:true


  def nearest_driver
    pickup_location = Location.get_location(pickup)
    customer_destination = Location.get_location(destination)
    drivers = Driver.where(area_id: pickup_location.area_id)
    origin_coordinate = eval(pickup_location.coordinate)

    drivers_dist = drivers.reduce(Hash.new) do |hash, driver|
      hash[driver.name] = Location.distance(origin_coordinate, driver.coordinate)
      hash
    end
    drivers_dist.min_by { |driver, length| length }
  end

  def nearest_all_drivers
    pickup_location = Location.get_location(pickup)
    customer_destination = Location.get_location(destination)
    drivers = Driver.all
    origin_coordinate = eval(pickup_location.coordinate)

    drivers_dist = drivers.reduce(Hash.new) do |hash, driver|
      hash[driver.name] = Location.distance(origin_coordinate, driver.coordinate)
      hash
    end

    drivers_dist.min_by { |driver, length| length }

  end

end
