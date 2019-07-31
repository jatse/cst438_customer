class Customer < ApplicationRecord
    #checks that name and email not empty
    validates_presence_of :email, :firstName, :lastName 
    
    #checks email validity
    #Start with no '@' or whitespace + '@' + End with alphanumeric or hyphen + . + 2 or more letters; case-insensitive
    validates :email, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
    validates_uniqueness_of :email
end