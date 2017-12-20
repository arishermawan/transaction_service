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

  context "subtract and add gopay after order" do
    before :each do
      @gopay1 = Gopay.new.add_record(20000.0, 1, 0)
      @gopay2 = Gopay.new.add_record(20000.0, 1, 1)
      @order = create(:order, payment:'gopay', customer_id:1, driver_id:1, total:10000.0)
      @order.subtract_gopay
      @order.add_gopay
      @gopay1.reload
      @gopay2.reload
    end

    describe "subtract gopay" do
      it "reduce customer gopay" do
        expect(@gopay1.credit).to eq(10000.0)
      end
    end

    describe "subtract gopay" do
      it "reduce customer gopay" do
        expect(@gopay2.credit).to eq(30000.0)  
      end
    end
  end
end
