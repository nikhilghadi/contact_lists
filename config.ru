# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server


use Rack::Cors do
  allow do
    origins 'http://localhost:3001'
            # regular expressions can be used here

            resource '/add_new_contact',
            :headers => :any,
            :methods => [:post]        # headers to expose


            resource '/search_phone_number',
            :headers => :any,
            :methods => [:get]      
  end

end