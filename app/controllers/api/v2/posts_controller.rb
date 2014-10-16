class Api::V2::PostsController < Rack::API::Controller

  def index
    posts = Post.filtered({ query: params[:query],
                            order_by: params[:order_by],
                            order_type: params[:order_type] }).
             paginated(params[:page], params[:per_page])
    { posts: posts }
  end

  def show
    set_post
    { post: @post, status: 200 }
  end

  def create
    set_post
    if @post.save
      status 201
      { post: @post, status: 201 }
    else
      error message: @post.errors.full_messages.join('\n'), status: 400
    end
  end

  def update
    sanitize_cookies
    set_post
    validate_ownership
    if @post.update(post_params)
      { post: @post, status: 200 }
    else
      error message: @post.errors.full_messages.join('\n'), status: 400
    end
  end

  def destroy
    sanitize_cookies
    set_post
    validate_ownership
    if @post.delete
      { status: 200 }
    else
      error message: 'Unable to destroy this resource', status: 400
    end
  end

  private

    def set_user
      if @cookies["auth_token"]
        @user = User.where(auth_token: @cookies["auth_token"]).first

        unless @user
          error message: 'Unable to find user.', status: 401
        end
      end
    end

    def set_post
      @post = (params[:id])? Post.find(params[:id]) : Post.new(post_params)
    end

    def post_params
      params[:post]
    end

    def validate_ownership
      set_user
      if @user && @user != @post.user
        error message: 'Unauthorized access.', status: 401
      end
    end

    def sanitize_cookies
      if request.env["Cookie"]
        @cookies = Hash.new
        cookies = request.env["Cookie"].split(';')
        cookies.each do |cookie|
          parts = cookie.split('=')
          @cookies[ parts[0] ] = parts[1]
        end
        @cookies
      end
    end
end
