class GopayValidator < ActiveModel::Validator
  def validate(record)

    if record.payment == "gopay"
      gopay = Customer.find(record.customer_id).gopay
      if gopay < record.calculate_total
        record.errors[:payment] << "gopay credit isn't enough"
      end
    end
  end
end
