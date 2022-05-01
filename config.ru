# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server


use Rack::Cors do
  allow do
    origins 'https://626ed32d276ce204132cfa5b--amazing-sunshine-8d59e1.netlify.app/'
            # regular expressions can be used here

            resource '/add_new_contact',
            :headers => :any,
            :methods => [:post]        # headers to expose


            resource '/search_phone_number',
            :headers => :any,
            :methods => [:get]      
  end

end