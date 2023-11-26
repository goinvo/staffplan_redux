json.extract! project, :id, :client_id, :name, :status, :company_id, :proposed, :cost, :payment_frequency, :created_at, :updated_at
json.url project_url(project, format: :json)
