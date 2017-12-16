class GopayCredit < ApplicationRecord
  enum user_type: {
    "Customer" => 0,
    "Driver" => 1
  }

  validates :credit, :user_id, :user_type, presence:true
  validates :credit, numericality:true


  def self.add_credit(amount, user_id, user_type)
    result = ''
    record = find_record(user_id, user_type)
    if !record.nil?
      credit_update = record.credit + amount
      update_record = record.update(credit: credit_update)
      result = record.credit
    else
      result = add_record(amount, user_id, user_type)
      result = result.credit
    end
    result
  end

  def self.reduce_credit(amount, user_id, user_type)
    result = ''
    record = find_record(user_id, user_type)
    if !record.nil?
      credit_update = record.credit - amount
      update_record = record.update(credit: credit_update)
      result = record.credit
    end
    result
  end

  def self.find_record(user_id, user_type)
    record = GopayCredit.find_by(user_id: user_id, user_type: user_type)
  end

  def self.add_record(amount, user_id, user_type)
    record = GopayCredit.create(credit:amount, user_id: user_id, user_type:user_type)
  end

end
