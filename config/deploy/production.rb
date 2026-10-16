set :branch, 'main'
set :rails_env, :production

server '54.219.182.164', user: 'shopify', roles: %w{app db web}
