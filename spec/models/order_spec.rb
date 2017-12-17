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
end
