class Location < ApplicationRecord

  belongs_to :area

  validates :address, presence:true, uniqueness:true
  validates :coordinate, presence:true

  def self.get_location(address)
    result = ''
    api_key = 'AIzaSyAT3fcxh_TKujSW6d6fP9cUtrexk0eEvAE'
    if !address.nil? && !address.empty?
      gmaps = GoogleMapsService::Client.new(key: api_key)
      address.downcase!
      get_api = gmaps.geocode(address)
      if !get_api.empty?
        area = get_api[0][:address_components]

        city = ''
        area.each do |type|
          if type[:types][0]=="administrative_area_level_2"
            city = type[:short_name].downcase
          end
        end

        check_area = save_area_not_exist(city)
        geometry = get_api[0][:geometry][:location]
        coordinate = [geometry[:lat], geometry[:lng]]
        check_location = save_location_not_exist(check_area, address, coordinate)
        result = check_location
      end
    end
    result
  end

  def self.save_area_not_exist(area)
    check_area = Area.find_by(name: area)
    if check_area == nil
      check_area = Area.create(name: area)
    end
    check_area
  end

  def self.save_location_not_exist(area, address, coordinate)
    check_location = Location.find_by(address: address)
    if check_location == nil
      check_location = area.location.create(address: address, coordinate: coordinate)
    end
    check_location
  end

  def self.distance(loc1, loc2)
    rad_per_deg = Math::PI/180
    rkm = 6371
    rm = rkm * 1000

    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg

    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c
  end

  def api_key
    api = 'AIzaSyAT3fcxh_TKujSW6d6fP9cUtrexk0eEvAE'
  end

  def get_google_api(pickup, destination)
    matrix = []
    gmaps = GoogleMapsService::Client.new(key: api_key)
    origins = pickup
    destinations = destination
    if !origins.empty? && !destinations.empty?
      matrix = gmaps.distance_matrix(origins, destinations, mode: 'driving', language: 'en-AU', avoid: 'tolls')
    end
    matrix
  end


  def distance_result(distance_params)
    result = Hash.new
    origin = distance_params[:origin]
    destination = distance_params[:destination]
    api = get_google_api(origin, destination)


    distance = 0
    origin_address = []
    destination_address = []

    if !api.empty?
       if api[:rows][0][:elements][0][:status] == "OK"
        distance = api[:rows][0][:elements][0][:distance][:value]
        distance = (distance.to_f / 1000).round(2)
      end

      origin_address = api[:origin_addresses]
      origin_address.reject! { |address| address.empty? }

      destination_address = api[:destination_addresses]
      destination_address.reject! { |address| address.empty? }
    end


    result[:origin] = origin_address
    result[:destination] = destination_address
    result[:distance] = distance
    result[:unit] = "KM"

    result
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

  def calculate_total
    total = 0
    if api_not_empty?
      total = distance_matrix * cost_per_km
    end
    self.total = total
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
