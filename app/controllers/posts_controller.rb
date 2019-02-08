class PostsController < ApplicationController
    before_action :set_corporation
    before_action :set_patients, only: [:new, :edit]

    def new
        @post = Post.new
    end

    def index
        @users = @corporation.cached_registered_users_ordered_by_kana
        @patients = @corporation.cached_active_patients_ordered_by_kana
                
        fetch_post_readers

        if params[:range_start].present? || params[:range_end].present? 
            @posts = @corporation.posts.where('created_at BETWEEN ? AND ?', params[:range_start], params[:range_end])
            @posts = @posts.where(patient_id: params[:patient_ids]) if params[:patient_ids].present? && (params[:patient_ids].map(&:to_i) - @patients.ids).empty?
            @posts = @posts.where(author_id: params[:author_ids]) if params[:author_ids].present? && (params[:author_ids].map(&:to_i) - @users.ids).empty?
        else
            @posts = @corporation.cached_recent_posts
        end
        

        respond_to do |format|
            format.html
            format.js
            format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"経過記録_#{Date.today.strftime("%-m月%-d日")}.xlsx\""}
        end
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

    def mark_all_posts_as_read
        Post.mark_as_read! :all, for: current_user
    end

    private

    def set_corporation
        @corporation = Corporation.cached_find(current_user.corporation_id)
    end

    def set_patients 
        @patients = @corporation.cached_active_patients_ordered_by_kana
    end

    def fetch_post_readers
        @posts_readers = {}
        @posts.each do |post|
            readers = @corporation.users.have_read(post).pluck(:name)
            @posts_readers[post.id] = readers 
        end
    end

    def post_params
        params.require(:post).permit(:body, :patient_id)
    end
end