set :branch, 'main'
set :rails_env, :staging

server '54.153.88.16', user: 'shopify', roles: %w{app db web}
