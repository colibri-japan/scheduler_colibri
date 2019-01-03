class ContactForm < MailForm::Base 
    attribute :name, validate: true
    attribute :company_name, validate: true
    attribute :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
    attribute :message

    attribute :nickname, captcha: true 

    def headers 
        {
            subject: 'お問い合わせフォーム',
            to: 'info@colibri.jp',
            from: %("#{name}" <#{email}>)
        }
    end
end