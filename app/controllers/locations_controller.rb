class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :update, :destroy]

  def index
    @locations = Location.all
    json_response(@locations)
  end

  def create
    @location = Location.create!(location_params)
    json_response(@location, :created)
  end

  def show
    json_response(@location)
  end

  def distance
    @location = Location.new.distance_result(distance_params)
    json_response(@location)
  end

  def update
    @location.update(location_params)
    head :no_content
  end

  def destroy
    @location.destroy
    head :no_content
  end

  private

  def location_params
    params.permit(:address, :coordinate, :area_id)
  end

  def distance_params
    params.permit(:origin, :destination)
  end

  def set_location
    @location = Location.find(params[:id])
  end
end
