class Api::V2::PostsController < Rack::API::Controller
  def index
    { posts: Post.all }
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
    set_post
    if @post.update(post_params)
      { post: @post, status: 200 }
    else
      error message: @post.errors.full_messages.join('\n'), status: 400
    end
  end

  def destroy
    set_post
    if @post.delete
      { status: 200 }
    else
      error message: 'Unable to destroy this resource', status: 400
    end
  end

  private

    def set_post
      @post = (params[:id])? Post.find(params[:id]) : Post.new(post_params)
    end

    def post_params
      params[:post];
    end
end
