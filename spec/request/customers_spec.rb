require 'rails_helper'

RSpec.describe 'Customer', type: :request do

  let(:customer) { create(:customer) }
  let!(:customers) { create_list(:customer, 10) }
  let(:customer_id) { customers.first.id }
  let(:headers) { valid_headers }

  describe 'GET /customers' do
    before { get '/customers', params: {}, headers: headers }
    it 'returns customers' do
      expect(json).not_to be_empty
      expect(json.size).to eq(11)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe'GET /customers/:id' do
    before { get "/customers/#{customer_id}", params: {}, headers: headers }

    context 'when the record exists' do
      it 'returns the customer' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(customer_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exists' do
      let(:customer_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Customer/)
      end
    end
  end

  describe 'POST /customers' do

    let(:valid_attributes) {
      { name: 'aris', email:'aris1@gmail.com', phone:'082310232303', password:'password', password_confirmation:'password' } 
    }

    context 'when the request is valid' do
      before { post '/customers', params: valid_attributes}

      it 'creates a customer' do
        expect(json['name']).to eq('aris')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/customers', params: { customer: attributes_for(:invalid_customer) } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match("{\"message\":\"Validation failed: Password can't be blank, Name can't be blank, Email can't be blank, Email is invalid, Phone can't be blank, Phone is not a number, Phone is too short (minimum is 6 characters)\"}"
)
      end
    end
  end

  describe 'PUT /customers/:id' do
    let(:valid_attributes) { { customer: attributes_for(:customer) }.to_json }

    context 'when the record exists' do
      before { put "/customers/#{customer_id}", params: valid_attributes, headers: headers }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  describe 'DELETE /customers/:id' do
    before { delete "/customers/#{customer_id}", params: {}, headers: headers }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
