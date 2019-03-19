module PostsHelper

    def post_was_published_at(post)
        post.published_at.strftime("%Y年%-m月%-d日 %H:%M")
    end
end