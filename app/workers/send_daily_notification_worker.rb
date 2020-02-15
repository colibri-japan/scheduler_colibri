class SendDailyNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(date_time)
        date = date_time.to_date rescue nil
        return if date.nil?

        android_registration_ids = []
        ios_registration_ids = []

        Nurse.with_operational_appointments_between(date.beginning_of_day, date.end_of_day).includes(:user).find_each do |nurse|
            user = nurse.user
            if user.present? && user.with_mobile_device?
                android_registration_ids << user.android_fcm_token if user.android_fcm_token.present?
                ios_registration_ids << user.ios_fcm_token if user.ios_fcm_token.present?
            end
        end

        android_registration_ids = android_registration_ids.flatten
        ios_registration_ids = ios_registration_ids.flatten

        send_android_notification(android_registration_ids) if android_registration_ids.present?
        send_ios_notification(ios_registration_ids) if ios_registration_ids.present?
    end

    private 

    def send_android_notification(registration_ids)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.registration_ids = registration_ids
        n.data = {title: 'おはようございます！', body: '本日のサービスのまとめです', url: 'https://scheduler.colibri.jp/users/current_user_home?to=planning&force_list_view=true'}
        n.content_available = true
        n.priority = 'high'
        if n.save!
            Rpush.push
        end
    end

    def send_ios_notification(registration_ids)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.notification = {title: 'おはようございます！', body: '本日のサービスのまとめです'}
        n.registration_ids = registration_ids
        n.content_available = true
        n.priority = 'high'
        n.data = {url: 'https://scheduler.colibri.jp/users/current_user_home?to=planning&force_list_view=true'}
        if n.save!
            Rpush.push 
        end
    end

end