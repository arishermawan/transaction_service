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

end
