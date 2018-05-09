class PagesController < ApplicationController
  layout 'pages'
  before_action :onboard_user!, only: :dashboard
  before_action :require_payment_method!, only: :dashboard

  def landing; end

  def contact_us
    if MessageMailer.contact_us(params[:body], params[:email], params[:name]).deliver
      redirect_to landing_path, flash: {
        success: 'Thanks for messaging us! We\'ll get back to you as soon as possible!'
      }
    else
      redirect_to landing_path, flash: {
        alert: 'Oh no, something wen\'t wrong! Contact us directly at contact@wcwlc.com'
      }
    end
  end

  def updates
    message = if MessageMailer.updates(params[:email]).deliver
                { success: 'Thanks for signing up for updates!' }
              else
                { alert: 'Oh no, something wen\'t wrong! Contact us directly at contact@wcwlc.com' }
              end
    Lead.create(email: params[:email], context: 'wants to receive updates')
    redirect_to landing_path, flash: message
  end

  def dashboard
    @stacks = current_user.stacks
  end
end
