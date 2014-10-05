Rack::API.app do
  prefix "api"

  version :v2 do
    get "status(.:format)" do
      {:success => true, :time => Time.now}
    end

    get     'users',      to: 'Api::V2::UserController#index'
    get     'users/:id',  to: 'Api::V2::UserController#show'
    put     'users/:id',  to: 'Api::V2::UserController#update'
    delete  'users/:id',  to: 'Api::V2::UserController#destroy'
    post    'users',      to: 'Api::V2::UserController#create'
  end
end
