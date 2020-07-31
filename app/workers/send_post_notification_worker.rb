class SendPostNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(user_id, post_id)
        @user = User.find(user_id)
        @post = Post.find(post_id)
        corporation = @user.corporation 
        nurse = @user.nurse 

        return unless @user.present?

        team = @user.team

        if team.present? 
            @recipients = team.users.not_a_restricted_nurse.with_mobile_devices
        else
            @recipients = corporation.users.not_a_restricted_nurse.with_mobile_devices
        end

        action = deduce_action_from_post_timestamps

        title = "#{@user.name}"
        body = set_body_from_action(action)

        @recipients.each do |r|
            #create a notification
            android_create_notification([r.android_fcm_token], title, body) if r.android_fcm_token.present?
            ios_create_notification([r.ios_fcm_token], title, body) if r.ios_fcm_token.present?
        end

        sleep(1)

        Rpush.push
    end

    private

    def deduce_action_from_post_timestamps
        if @post.created_at == @post.updated_at
            :create 
        else
            :update 
        end
    end

    def set_body_from_action(action)
        case action 
        when :create 
            "掲示板に新規書き込みが届いています"
        when :update 
            "掲示板に上書きしました"
        end
    end

    def android_create_notification(registration_ids, title, body)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.registration_ids = registration_ids
        n.content_available = true
        n.priority = 'high'
        n.data = {title: title, body: body, url: "https://scheduler.colibri.jp/dashboard"}
        n.save!
    end

    def ios_create_notification(registration_ids, title, body)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.notification = {title: title, body: body}
        n.registration_ids = registration_ids
        n.content_available = true
        n.priority = 'high'
        n.data = {url: "https://scheduler.colibri.jp/dashboard"}
        n.save! 
    end

end