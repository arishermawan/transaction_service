require 'rails_helper'

RSpec.describe 'Order', type: :request do

  let!(:orders) { create_list(:order, 10) }
  let(:order_id) { orders.first.id }

  describe 'GET /orders' do
    before { get '/orders' }
    it 'returns orders' do
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe'GET /orders/:id' do
    before { get "/orders/#{order_id}" }

    context 'when the record exists' do
      it 'returns the order' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(order_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exists' do
      let(:order_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Order/)
      end
    end
  end

  describe 'POST /orders' do

    let(:valid_attributes) {
      {
        pickup: "kolla sabang",
        destination: "sarinah mall",
        payment: 'cash',
        distance: 9.99,
        total: 9000,
        service: "goride",
        customer_id: 1,
        driver_id: 5
      }
    }

    context 'when the request is valid' do
      before { post '/orders', params: valid_attributes}

      it 'creates a order' do
        expect(json['pickup']).to eq("kolla sabang")
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/orders', params: { order: attributes_for(:invalid_order) } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"message\":\"Validation failed: Customer must exist, Payment is not included in the list, Payment can't be blank, Service is not included in the list, Pickup can't be blank, Destination can't be blank\"}"
)
      end
    end
  end

  describe 'PUT /orders/:id' do
    let(:valid_attributes) { { order: attributes_for(:order) } }

    context 'when the record exists' do
      before { put "/orders/#{order_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /orders/:id' do
    before { delete "/orders/#{order_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
