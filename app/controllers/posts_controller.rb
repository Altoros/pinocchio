class PostsController < ApplicationController

  skip_before_filter :authenticate_user, only: [:show, :index]

  before_action :authorize_resource, only: [:edit, :update, :destroy]

  prepend_before_action :set_post, except: [:index]

  def index
    @posts = Post.all
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @post.user = current_user

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize(@post)
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
    end
  end

  private

  def set_post
    @post ||= (
       if params[:id]
         Post.find(params[:id])
       else
         Post.new(post_params || {})
       end
    )
  end

  def post_params
    params.require(:post).permit(:title, :body) if params[:post].present?
  end

  def authorize_resource
    authorize(@post)
  end
end
