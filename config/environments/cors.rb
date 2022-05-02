Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins 'https://amazing-sunshine-8d59e1.netlify.app/'
      resource '*', headers: :any, methods: [:get, :post, :patch, :put]
    end
  end

 
