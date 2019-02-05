class PostsController < ApplicationController
    before_action :set_corporation
    before_action :set_patients, only: [:new, :edit]

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
        @corporation = Corporation.cached_find(current_user.corporation_id)
    end

    def set_patients 
        @patients = @corporation.cached_active_patients_ordered_by_kana
    end

    def post_params
        params.require(:post).permit(:body, :patient_id)
    end
end