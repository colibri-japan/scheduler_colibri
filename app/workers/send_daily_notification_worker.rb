class SendDailyNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(date_time)
        date = date_time.to_date rescue nil
        return if date.nil?

        Nurse.with_operational_appointments_between(date.beginning_of_day, date.end_of_day).includes(:user).find_each do |nurse|
            user = nurse.user
            if user.present? && user.with_mobile_device?
                save_android_notification([user.android_fcm_token]) if user.android_fcm_token.present?
                save_ios_notification([user.ios_fcm_token]) if user.ios_fcm_token.present?
            end
        end

        #make sure that all notifications are properly saved in the db
        sleep(10)

        #push the batch of notifications with Rpush
        Rpush.push
    end

    private 

    def save_android_notification(registration_ids)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.registration_ids = registration_ids
        n.content_available = true
        n.priority = 'high'
        if n.save!
            n.data = {title: 'おはようございます！', body: '本日のサービスのまとめです', url: "https://scheduler.colibri.jp/users/current_user_home?to=planning&force_list_view=true&notification_id=#{n.id}"}
            n.save!
        end
    end

    def save_ios_notification(registration_ids)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.notification = {title: 'おはようございます！', body: '本日のサービスのまとめです'}
        n.registration_ids = registration_ids
        n.content_available = true
        n.priority = 'high'
        
        if n.save!
            n.data = {url: "https://scheduler.colibri.jp/users/current_user_home?to=planning&force_list_view=true&notification_id=#{n.id}"}
            n.save! 
        end
    end

end