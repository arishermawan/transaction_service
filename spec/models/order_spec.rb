require 'rails_helper'

RSpec.describe Order, type: :model do

  it "has a valid factory" do
    expect(build(:order)).to be_valid
  end

  it "is valid with a pickup, destination, payment, distance and total" do
    expect(build(:order)).to be_valid
  end

  it "is invalid without a pickup" do
    order = build(:order, pickup: '')
    order.valid?
    expect(order.errors[:pickup]).to include("can't be blank")
  end

  it "is invalid without a destination" do
    order = build(:order, destination: '')
    order.valid?
    expect(order.errors[:destination]).to include("can't be blank")
  end

  it "is invalid without a payment type" do
    order = build(:order, payment: nil)
    order.valid?
    expect(order.errors[:payment]).to include("can't be blank")
  end

  it "is invalid with wrong pick up address" do
    order = build(:order, pickup: "azsxdcfewasqfx")
    order.valid?
    expect(order.errors[:pickup]).to include("is not found")
  end

  it "is invalid with wrong destination address" do
    order = build(:order, destination: "azsxdcfewasqfx")
    order.valid?
    expect(order.errors[:destination]).to include("is not found")
  end

  it "is invalid with wrong destination address" do
    order = build(:order, destination: "azsxdcfewasqfx")
    order.valid?
    expect(order.errors[:destination]).to include("is not found")
  end

  it "is invalid with distance more than 25 km" do
    order = build(:order, pickup: "jakarta", destination: "bandung")
    order.valid?
    expect(order.errors[:destination]).to include("distance is greater than 25 km, we only serve maximum 25 km")
  end

  it "is invalid with wrong destination address" do
    order = build(:order, service: nil)
    order.valid?
    expect(order.errors[:service]).to include("is not included in the list")
  end

  context "create method request to google api" do
    before :each do
      @order = build(:order, pickup:'kolla sabang', destination:'sarinah mall')
      @get_api = @order.get_google_api

      @invalid_order = build(:order, pickup:'', destination:'')
      @invalid_get_api = @invalid_order.get_google_api
    end

    describe "get_google_api" do
      context "with valid attributes" do
        it "return array from request google api service" do
          expect(@get_api.empty?).to eq(false)
        end

        it "return ok status" do
          expect(@get_api[:status]).to eq('OK')
        end
      end

      context "with invalid attributes" do
        it "return an empty array" do
          expect(@invalid_get_api.empty?).to eq(true)
        end
      end
    end

    describe "pickup_address" do
      it "return address from pickup location" do
        expect(@order.pickup_address.empty?).not_to eq (true)
      end
    end

    describe "destination_address" do
      it "return address from destination location" do
        expect(@order.destination_address.empty?).not_to eq (true)
      end
    end

    describe "distance_matrix" do
      it "get distance from pickup & destination" do
        expect(@order.distance_matrix).to eq (1.0)
      end

      it "it return 1 km if distance less than 1.0 km" do
        expect(@order.distance_matrix).to eq (1.0)
      end
    end

    describe "cost_per_km" do
      it "get Rp 1500 if service type goride" do
        order = build(:order, service:'goride')
        expect(order.cost_per_km).to eq (1500)
      end

      it "get Rp 2500 if service type gocar" do
        order = build(:order, service:'gocar')
        expect(order.cost_per_km).to eq (2500)
      end
    end

    describe "calculate_total" do
      context "using goride service" do
        it "calculate cost from distance and cost per km price" do
          order = build(:order, pickup: "kolla sabang", destination: "sarinah", service:'goride')
          expect(@order.calculate_total).to eq (1500.0)
        end
      end

      context "using gocar service" do
        it "calculate cost from distance and cost per km price" do
          order = build(:order, pickup: "kolla sabang", destination: "sarinah", service:'gocar')
          expect(order.calculate_total).to eq (2500.0)
        end
      end
    end

    describe "api_not_empty?" do
      it "return true if google api is not empty" do
        expect(@order.api_not_empty?).to eq(true)
      end

      it "return false if google_api is empty" do
        expect(@invalid_order.api_not_empty?).to eq(false)
      end
    end
  end
end
