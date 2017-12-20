require 'rails_helper'

RSpec.describe Gopay, type: :model do

  it "has a valid factory" do
    expect(build(:gopay)).to be_valid
  end

  it "is valid with credit, user_id and type" do
    expect(build(:gopay)).to be_valid
  end

  it "is invalid without credit" do
    gopay = build(:gopay, credit:nil)
    gopay.valid?
    expect(gopay.errors['credit']).to include('is not a number')
  end

  it "is invalid without user_id" do
    gopay = build(:gopay, user_id:nil)
    gopay.valid?
    expect(gopay.errors['user_id']).to include("can't be blank")
  end

  it "is invalid without user_type" do
    gopay = build(:gopay, user_type:nil)
    gopay.valid?
    expect(gopay.errors['user_type']).to include("can't be blank")
  end

  it "is invalid with duplicate user_id & user_type" do
  end


  describe "add_credit" do
    it 'add amount of credit' do
      gopay = create(:gopay)
      gopay.add_credit(credit: 10000.0)
      gopay.add_credit(credit: 10000.0)
      gopay.reload
      expect(gopay.credit).to eq(20000.0)
    end
  end

  describe "reduce_credit" do
    it 'reduce amount of credit' do
      gopay = create(:gopay)
      gopay.add_credit(credit:10000.0)
      gopay.add_credit(credit:10000.0)
      gopay.reduce_credit(credit:15000.0)
      gopay.reload
      expect(gopay.credit).to eq(5000.0)
    end
  end

  describe "find_record" do
    it 'return gopay object if found' do
      gopay1 = create(:gopay)
      gopay2 = Gopay.new.find_record(1, 'Customer')
      expect(gopay2).to eq(gopay1)
    end
  end

  describe "add_record" do
    it 'create new record of gopay' do
      gopay = Gopay.new.add_record(10000, 1, 0)
      gopay.reload
      expect(gopay.credit).to eq(10000.0)
    end
  end
end
