class Gopay < ApplicationRecord
  enum user_type: {
    "Customer" => 0,
    "Driver" => 1
  }

  before_save :update_gopay_application_services

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

  def add_record(credit, user_id, user_type)
    record = Gopay.create(credit:credit, user_id: user_id, user_type:user_type)
  end

  def update_gopay_application_services
    require 'kafka'
    kafka = Kafka.new( seed_brokers: ['localhost:9092'], client_id: 'transaction-service')
    gopay = Hash.new
    gopay[:credit] = credit
    gopay[:user_id] = user_id
    gopay[:user_type] = user_type
    kafka.deliver_message("UPDATEGOPAY-->#{gopay.to_json}", topic: 'applicationServices')
  end

end
