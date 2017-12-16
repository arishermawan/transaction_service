require 'rails_helper'

RSpec.describe GopayCredit, type: :model do

  it "has a valid factory" do
    expect(build(:gopay_credit)).to be_valid
  end

  it "is valid with credit, user_id and type" do
    expect(build(:gopay_credit)).to be_valid
  end

  it "is invalid without credit" do
    gopay = build(:gopay_credit, credit:nil)
    gopay.valid?
    expect(gopay.errors['credit']).to include('is not a number')
  end

  it "is invalid without user_id" do
    gopay = build(:gopay_credit, user_id:nil)
    gopay.valid?
    expect(gopay.errors['user_id']).to include("can't be blank")
  end

  it "is invalid without user_type" do
    gopay = build(:gopay_credit, user_type:nil)
    gopay.valid?
    expect(gopay.errors['user_type']).to include("can't be blank")
  end

  it "is invalid with duplicate user_id & user_type" do
  end


  describe "add_credit" do
    it 'add amount of credit' do
      user_type = 'Customer'
      credit = create(:gopay_credit, user_id:1, user_type: user_type)
      GopayCredit.add_credit(10000, 1, user_type)
      gopay = GopayCredit.find_record(1,user_type)
      expect(gopay.credit).to eq(10000.0)
    end

    it 'add record if not exist' do
      user_type = 'Customer'
      GopayCredit.add_credit(10000, 1, user_type)
      gopay = GopayCredit.find_record(1,user_type)
      expect(gopay.credit).to eq(10000.0)
    end
  end

  describe "reduce_credit" do
    it 'reduce amount of credit' do
      user_type = 'Customer'
      credit = create(:gopay_credit, id:1 ,credit:10000, user_id:1, user_type: user_type)
      GopayCredit.reduce_credit(10000, 1, user_type)
      gopay = GopayCredit.find_record(1, user_type)
      expect(gopay.credit).to eq(0.0)
    end
  end

  describe "find_record" do
    it 'return gopay_credit object if found' do
      user_type = 'Customer'
      credit = create(:gopay_credit, id:1 ,credit:10000, user_id:1, user_type: user_type)
      gopay = GopayCredit.find_record(1, user_type)
      expect(gopay.credit).to eq(10000.0)
    end
  end

  describe "add_record" do
    it 'create new record of gopay_credit' do
      user_type = 'Customer'
      GopayCredit.add_record(10000, 1, 0)
      gopay = GopayCredit.find_record(1, user_type)
      expect(gopay.credit).to eq(10000.0)
    end
  end
end
