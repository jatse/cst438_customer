class CustomersController < ApplicationController
    #===========================================================================
    #Adds a new customer to database.
    #POST /customers
    #===========================================================================
    def create
        customer = Customer.new(customer_params)
        
        if customer.save
            #calls function to format hash
            data = format_customer(customer)
            render(json: data, status: 201)
        else
            render(json: customer.errors, status:400)
        end
    end
    
    
    #===========================================================================
    #Search for customer based on GET parameters (id or email)
    #GET /customers
    #===========================================================================
    def index
        #pull customer based on params given
        if params.has_key?(:id)
            customer = Customer.find_by(id: params['id'])
        elsif params.has_key?(:email)
            customer = Customer.find_by(email: params['email'])
        end
        
        #return customer info if found
        if customer != nil
            data = format_customer(customer)
            render(json: data, status: 200)
        else
            head :not_found
        end
    end
    
    
    #===========================================================================
    #Updates customer's orders and award
    #Currently assumes valid item
    #PUT /customers/order
    #===========================================================================
    def order
        #find customer
        if params.has_key?(:customerId)
            customer = Customer.find_by(id: params['customerId'])
        end
        
        #checks for invalid user id
        if customer == nil
            head :bad_request
            return  #stops execution if invalid user
        end
        
        #update customer record base on order
        #clear previous orders if award had been generated
        if customer.award > 0
            customer.lastOrder = 0
            customer.lastOrder2 = 0
            customer.lastOrder3 = 0
            customer.award = 0
        #otherwise populate 3 orders
        elsif customer.lastOrder == 0
            customer.lastOrder = params['total']
        elsif customer.lastOrder2 == 0
            customer.lastOrder2 = params['total']
        elsif customer.lastOrder3 == 0
            customer.lastOrder3 = params['total']
            #calculate award when 3rd order is fulfilled
            customer.award = ((customer.lastOrder + customer.lastOrder2 + customer.lastOrder3)/30)
        end
        
        #save updated record to database
        if customer.save
            head :no_content
        else
            head :bad_request
        end
    end
    
    
    private
        #=======================================================================
        #returns hash of Customer object's attributes from db
        #use email to find customer
        #=======================================================================
        def format_customer(customer)
            return {
                :id => customer.id,
                :email => customer.email, 
                :firstName => customer.firstName, 
                :lastName => customer.lastName,
                :lastOrder => customer.lastOrder,
                :lastOrder2 => customer.lastOrder2,
                :lastOrder3 => customer.lastOrder3,
                :award => customer.award
            }
        end
            
        #=======================================================================    
        #Sanitizes input parameters for new customers
        #=======================================================================
        def customer_params
          params.require(:customer).permit(:email, :firstName, :lastName)
        end
end