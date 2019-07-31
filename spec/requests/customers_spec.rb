require 'rails_helper'

RSpec.describe 'Customers' do
    headers = {'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'}
    
    #seed database
    before(:each) do 
        Customer.create(email: 'something@yahoo.com', firstName: 'Bob', lastName: 'Jackson')
        Customer.create(email: 'mwalk76@gmail.com', firstName: 'Mary', lastName: 'Walker')
        Customer.create(email: 'dlee@att.net', firstName: 'Dave', lastName: 'Lee')
    end 
    
    describe "POST /customers" do
        it 'creates a valid customer' do
            customer_new = {email: 'jdoe@gmail.com', firstName: 'John', lastName: 'Doe'}
            post '/customers', params: customer_new.to_json, headers: headers
            expect(response).to have_http_status(201)
            json_response = JSON.parse(response.body)
            expect(json_response['id']).to eq 4
            expect(json_response['email']).to eq 'jdoe@gmail.com'
            expect(json_response['firstName']).to eq 'John'
            expect(json_response['lastName']).to eq 'Doe'
            expect(json_response['lastOrder']).to eq '0.0'
            expect(json_response['lastOrder2']).to eq '0.0'
            expect(json_response['lastOrder3']).to eq '0.0'
            expect(json_response['award']).to eq '0.0'
        end
        
        it 'faults on bad email' do
            customer_new = {email: 'bob', firstName: 'John', lastName: 'Doe'}
            post '/customers', params: customer_new.to_json, headers: headers
            expect(response).to have_http_status(400)
            json_response = JSON.parse(response.body)
            expect(json_response['email']).to eq ["is invalid"]
        end
        
        it 'faults on missing fields' do
            customer_new = {email: '', firstName: ''}
            post '/customers', params: customer_new.to_json, headers: headers
            expect(response).to have_http_status(400)
            json_response = JSON.parse(response.body)
            expect(json_response['email']).to eq ["can't be blank", "is invalid"]
            expect(json_response['firstName']).to eq ["can't be blank"]
            expect(json_response['lastName']).to eq ["can't be blank"]
        end
    end
    
    describe "GET /customers" do
        it 'finds customer by id' do
            get '/customers?id=2', headers: headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response['id']).to eq 2
            expect(json_response['email']).to eq 'mwalk76@gmail.com'
            expect(json_response['firstName']).to eq 'Mary'
            expect(json_response['lastName']).to eq 'Walker'
            expect(json_response['lastOrder']).to eq '0.0'
            expect(json_response['lastOrder2']).to eq '0.0'
            expect(json_response['lastOrder3']).to eq '0.0'
            expect(json_response['award']).to eq '0.0'
        end
        
        it 'finds customer by email' do
            get '/customers?email=dlee@att.net', headers: headers
            expect(response).to have_http_status(200)
            json_response = JSON.parse(response.body)
            expect(json_response['id']).to eq 3
            expect(json_response['email']).to eq 'dlee@att.net'
            expect(json_response['firstName']).to eq 'Dave'
            expect(json_response['lastName']).to eq 'Lee'
            expect(json_response['lastOrder']).to eq '0.0'
            expect(json_response['lastOrder2']).to eq '0.0'
            expect(json_response['lastOrder3']).to eq '0.0'
            expect(json_response['award']).to eq '0.0'
        end 
        
        it '404 on wrong search parameters' do
            get '/customers?email=somebody@proxy.org', headers: headers
            expect(response).to have_http_status(404)
        end
        
        it '404 on no search parameters' do
            get '/customers', headers: headers
            expect(response).to have_http_status(404)
        end
    end
    
    describe 'PUT /customers/order' do
        it 'makes purchases, calculate award, and resets' do
            customer = Customer.find_by(id: 1)
            expect(customer['id']).to eq 1
            expect(customer['email']).to eq 'something@yahoo.com'
            expect(customer['firstName']).to eq 'Bob'
            expect(customer['lastName']).to eq 'Jackson'
            expect(customer['lastOrder']).to eq 0.0
            expect(customer['lastOrder2']).to eq 0.0
            expect(customer['lastOrder3']).to eq 0.0
            expect(customer['award']).to eq 0.0
            
            #first purchase
            order_new = {id: 1, itemid: 1, description: "ring", customerId: 1, price: 100, award: 0, total: 100}
            put '/customers/order', params: order_new.to_json, headers: headers
            expect(response).to have_http_status(204)
            customer = Customer.find_by(id: 1)
            expect(customer['lastOrder']).to eq 100
            expect(customer['lastOrder2']).to eq 0.0
            expect(customer['lastOrder3']).to eq 0.0
            expect(customer['award']).to eq 0.0
            
            #second purchase
            order_new = {id: 2, itemid: 2, description: "necklace", customerId: 1, price: 200, award: 0, total: 200}
            put '/customers/order', params: order_new.to_json, headers: headers
            expect(response).to have_http_status(204)
            customer = Customer.find_by(id: 1)
            expect(customer['lastOrder']).to eq 100
            expect(customer['lastOrder2']).to eq 200
            expect(customer['lastOrder3']).to eq 0.0
            expect(customer['award']).to eq 0.0
            
            #third purchase
            order_new = {id: 3, itemid: 3, description: "bracelet", customerId: 1, price: 175, award: 0, total: 175}
            put '/customers/order', params: order_new.to_json, headers: headers
            expect(response).to have_http_status(204)
            customer = Customer.find_by(id: 1)
            expect(customer['lastOrder']).to eq 100
            expect(customer['lastOrder2']).to eq 200
            expect(customer['lastOrder3']).to eq 175
            expect(customer['award']).to eq 15.83
            
            #fourth purchase
            order_new = {id: 4, itemid: 4, description: "ring", customerId: 1, price: 500, award: 15.83, total: 484.17}
            put '/customers/order', params: order_new.to_json, headers: headers
            expect(response).to have_http_status(204)
            customer = Customer.find_by(id: 1)
            expect(customer['lastOrder']).to eq 0.0
            expect(customer['lastOrder2']).to eq 0.0
            expect(customer['lastOrder3']).to eq 0.0
            expect(customer['award']).to eq 0.0
        end
        
        it 'faults on invalid user' do
            order_new = {id: 1, itemid: 1, description: "ring", customerId: 100, price: 100, award: 0, total: 100}
            put '/customers/order', params: order_new.to_json, headers: headers
            expect(response).to have_http_status(400)
        end
    end
end