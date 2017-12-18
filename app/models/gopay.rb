class Gopay < ApplicationRecord
  enum user_type: {
    "Customer" => 0,
    "Driver" => 1
  }

  validates :credit, :user_id, :user_type, presence:true
  validates :credit, numericality:true


  def add_credit(update_params)
    credit_update = credit + update_params[:credit].to_f
    self.update(credit: credit_update)
  end

  def reduce_credit(update_params)
    credit_update = credit - update_params[:credit].to_f
    self.update(credit: credit_update)
  end

  def find_record(user_id, user_type)
    record = Gopay.find_by(user_id: user_id, user_type: user_type)
  end

  def add_record(amount, user_id, user_type)
    record = Gopay.create(credit:amount, user_id: user_id, user_type:user_type)
  end

end
