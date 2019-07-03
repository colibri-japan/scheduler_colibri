class PostsController < ApplicationController
    before_action :set_corporation
    before_action :set_patients, only: [:new, :edit]

    def new
        @post = Post.new
        @post.reminders.build
    end

    def posts_widget
        @read_posts = current_user.cached_recent_read_posts
        @unread_posts = current_user.unread_posts
        @unread_ids = @unread_posts.ids
        @unread_count = @unread_posts.count
    end

    def index
        @users = @corporation.cached_registered_users_ordered_by_kana
        patients = @corporation.cached_all_patients_ordered_by_kana
        @patients_for_select = [['利用者タグなし', 'nil']] + patients.pluck(:name, :id)

        if params[:patient_ids].present? || params[:author_ids].present? || params[:range_start].present?
            @posts = @corporation.posts.includes(:reminders).order(published_at: 'DESC')
            @posts = @posts.where('published_at BETWEEN ? AND ?', params[:range_start], params[:range_end]) if params[:range_start].present? && params[:range_end].present?
            @posts = @posts.where(author_id: params[:author_ids]) if params[:author_ids].present? && (params[:author_ids].map(&:to_i) - @users.ids).empty?
            if params[:patient_ids].present? 
                if params[:patient_ids].include? 'nil'
                    posts_without_patient = @posts.left_outer_joins(:patient_posts).where(patient_posts: {id: nil})
                    posts_with_patients = @posts.joins(:patient_posts).where(patient_posts: {patient_id: params[:patient_ids]}) if ((params[:patient_ids] - ['nil']).map(&:to_i) - patients.ids).empty?
                    puts 'posts with patients'
                    puts posts_with_patients
                    @posts = (posts_without_patient + (posts_with_patients || [])).uniq
                else
                    @posts = @posts.joins(:patients).where(patients: {id: params[:patient_ids]}) if (params[:patient_ids].map(&:to_i) - patients.ids).empty?
                end
            end
        else
            @posts = @corporation.cached_recent_posts
        end

        fetch_post_readers

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
        @post.patients << Patient.where(id: post_params[:patient_id])
        @post.save
        mark_post_as_read
    end

    def edit
        @post = Post.find(params[:id])
        @post.reminders.build if @post.reminders.none?
    end

    def update
        @post = Post.find(params[:id])
        @post.update(post_params)
        @post_readers = @corporation.users.registered.have_read(@post).pluck(:name)
        mark_post_as_read
    end

    def destroy
        @post = Post.find(params[:id])

        @post.destroy
    end

    def mark_all_posts_as_read
        Post.mark_as_read! :all, for: current_user
        current_user.touch
    end

    private

    def set_patients 
        @patients = @corporation.cached_active_patients_ordered_by_kana
    end

    def fetch_post_readers
        @posts_readers = {}
        @posts.each do |post|
            readers = @corporation.users.registered.have_read(post).pluck(:name)
            @posts_readers[post.id] = readers 
        end
    end

    def mark_post_as_read
        if @post.reminders.any? 
            @post.corporation.users.each do |user|
                @post.mark_as_read! for: user
            end
        else
            @post.mark_as_read! for: current_user
        end
    end

    def post_params
        params.require(:post).permit(:published_at, :body, patient_ids: [], reminders_attributes: [:id, :anchor, :frequency, :_destroy])
    end
end