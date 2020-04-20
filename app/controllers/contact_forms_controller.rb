class ContactFormsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  layout 'contact_form'

  def new
    @contact_form = ContactForm.new()
  end

  def create
    @contact_form = ContactForm.new(params[:contact_form])
    @contact_form.request = request

    if @contact_form.deliver
      redirect_to pages_path(:thank_you)
    else
      redirect_to new_contact_form_path, alert: 'メールの送信が失敗しました'
    end
  end

end
