class SendDailyNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(date_time)
        date = date_time.to_date rescue nil
        return if date.nil?

        registration_ids = []

        Nurse.with_operational_appointments_between(date.beginning_of_day, date.end_of_day).includes(:user).find_each do |nurse|
            user = nurse.user
            if user.present? && user.with_mobile_device?
                registration_ids << user.android_fcm_token if user.android_fcm_token.present?
                registration_ids << user.ios_fcm_token if user.ios_fcm_token.present?
            end
        end

        registration_ids = registration_ids.flatten
        send_notification(registration_ids)
    end

    private 

    def send_notification(registration_ids)
        app = Rpush::Gcm::App.find_by_name("Colibri")
        n = Rpush::Gcm::Notification.new 
        n.app = app 
        n.registration_ids = registration_ids
        n.data = {title: 'おはようございます！', body: '本日のサービスのまとめです', url: 'https://colibri-scheduler-staging.herokuapp.com/users/current_user_home?to=planning'}
        n.content_available = true
        n.priority = 'high'
        if n.save!
            Rpush.push
        end
    end

end