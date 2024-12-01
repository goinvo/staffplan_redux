Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhost:8080"
      "ui.staffplan.com"

    resource "/graphql",
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options, :head],
             credentials: true,
             max_age: 86400
  end
end
