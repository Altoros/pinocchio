Rack::API.app do
  prefix "api"

  version :v2 do
    get "status(.:format)" do
      {:success => true, :time => Time.now}
    end

    get     'users',      to: 'Api::V2::UsersController#index'
    get     'users/:id',  to: 'Api::V2::UsersController#show'
    put     'users/:id',  to: 'Api::V2::UsersController#update'
    delete  'users/:id',  to: 'Api::V2::UsersController#destroy'
    post    'users',      to: 'Api::V2::UsersController#create'

    get     'posts',      to: 'Api::V2::PostsController#index'
    get     'posts/:id',  to: 'Api::V2::PostsController#show'
    put     'posts/:id',  to: 'Api::V2::PostsController#update'
    delete  'posts/:id',  to: 'Api::V2::PostsController#destroy'
    post    'posts',      to: 'Api::V2::PostsController#create'
  end
end
