class PostsController < ApplicationController
    before_action :set_corporation

    def new
        @post = Post.new
    end

    def create
        @post = Post.new(post_params)
        @post.author = current_user
        @post.corporation = @corporation 
        
        @post.save
    end

    def edit
        @post = Post.find(params[:id])
    end

    def update
        @post = Post.find(params[:id])

        @post.update(post_params)
    end

    def destroy
        @post = Post.find(params[:id])

        @post.destroy
    end

    private

    def set_corporation
        @corporation = current_user.corporation
    end

    def post_params
        params.require(:post).permit(:body)
    end
end