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

  it "is invalid with wrong destination address" do
    order = build(:order, service: nil)
    order.valid?
    expect(order.errors[:service]).to include("is not included in the list")
  end
end
