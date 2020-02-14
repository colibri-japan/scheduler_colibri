module PostsHelper

    def post_was_published_at(post)
        post.published_at.strftime("%Y年%-m月%-d日 %H:%M")
    end

    def post_patients_names(patient_names_array)
        if patient_names_array.size <= 3
            " > #{patient_names_array.join('、')}"
        else
            " > #{patient_names_array[0..2].join('、')} (その他#{patient_names_array.size - 3}人)"
        end
    end

    def post_form_title(post)
        if post.new_record?
            '新規書き込み'
        else
            '書き込みの編集'
        end
    end
end