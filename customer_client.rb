require 'httparty'

#HTTParty class for common request configuations
class Connection
    include HTTParty
    
    base_uri 'http://localhost:8080/'
    headers 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json'
    format :json
end

#initialize choice
choice = nil

def outputResponse(response)
    puts "status code #{response.code}"
    puts response
    puts #new line
end

#main application loop
while choice != 'quit' do
    #prompt user
    puts "What do you want to do: register, email, id or quit"
    choice = gets.chomp!
    
    
    case choice
        #adds new customer
        when 'register'
            #get new customer parameters
            puts "enter lastName, firstName and email for new customer"
            #convert input into a hash
            userInput = gets.chomp!.split
            obj = {'lastName' => userInput[0], 'firstName' => userInput[1], 'email' => userInput[2]}
            #print response object from request
            outputResponse(Connection.post('/customers', :body => obj.to_json))
            
        #finds customer from email
        when 'email'  
            #get email to search
            puts "enter email"
            userInput = gets.chomp!
            #print response object from request
            outputResponse(Connection.get('/customers', query: {email: userInput}))
            
        #finds customer from id
        when 'id'  
            #get id to search
            puts "enter id"
            userInput = gets.chomp!
            #print response object from request
            outputResponse(Connection.get('/customers', query: {id: userInput}))
    end
end