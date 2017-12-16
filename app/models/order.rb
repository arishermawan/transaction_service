class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :driver, optional: true

  before_save :calculate_total, :distance_matrix

  enum service: {
    "goride" => 0,
    "gocar" => 1
  }

  enum payment: {
    "cash" => 0,
    "gopay" => 1
  }

  validates_with OrderLocationValidator
  validates_with GopayValidator
  validates :payment, inclusion: payments.keys
  validates :service, inclusion: services.keys
  validates :pickup, :destination, :payment, presence:true

  def api_key
    api = 'AIzaSyAT3fcxh_TKujSW6d6fP9cUtrexk0eEvAE'
  end

  def get_google_api
    matrix = []
    gmaps = GoogleMapsService::Client.new(key: api_key)
    origins = pickup
    destinations = destination
    if !origins.empty? && !destinations.empty?
      matrix = gmaps.distance_matrix(origins, destinations, mode: 'driving', language: 'en-AU', avoid: 'tolls')
    end
    matrix
  end

  def pickup_address
    result = []
    if api_not_empty?
      result = get_google_api[:origin_addresses]
      result.reject! { |address| address.empty? }
    end
    result
  end

  def destination_address
    result = []
    if api_not_empty?
      result = get_google_api[:destination_addresses]
      result.reject! { |address| address.empty? }
    end
    result
  end

  def distance_matrix
    result = 0
    if api_not_empty?
      if get_google_api[:rows][0][:elements][0][:status] == "OK"
        result = get_google_api[:rows][0][:elements][0][:distance][:value]
        result = (result.to_f / 1000).round(2)
        result = 1.0 if result < 1.0
      end
    end
    self.distance = result
  end

  def cost_per_km
    service == 'gocar' ? 2500 : 1500
  end

  def calculate_total
    total = 0
    if api_not_empty?
      total = distance_matrix * cost_per_km
    end
    self.total = total
  end

  def gopay_sufficient?
    result = false
    if api_not_empty?
      result = true if customer.gopay >= calculate_total
    end
    result
  end

  def api_not_empty?
    !get_google_api.empty?
  end

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
