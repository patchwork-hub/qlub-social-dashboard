# frozen_string_literal: true

module Api
  module V1
    class WaitListController < ApiController
      skip_before_action :verify_key!
      def create
        wait_list = WaitList.new
        wait_list.generate_invitation_code
        if wait_list.save!
          render json: { data: wait_list}, status: 200
        else
          render json: { errors: wait_list.errors.full_messages }, status: 422
        end
      end

      def request_invitation_code
        email = params[:email]
        if email.present?
          wait_list = WaitList.find_or_create_by(email: email, used: false) do |wl|
            wl.description = params[:description]
            wl.generate_invitation_code
          end
          if wait_list.persisted?
            WaitListMailer.with(email: email,invitation_code: wait_list.invitation_code).send_invitation_code.deliver_later
            render json: { message: 'Invitation code sent to your email.' }, status: 200
          else
            render json: { error: wait_list.errors.full_messages }, status: 422
          end
        else
          render json: { error: 'Email is required.' }, status: 400
        end
      end

      def validate_code
        invitation_code = params[:invitation_code]
        if invitation_code.present? && WaitList.exists?(invitation_code: invitation_code, used: false)
          render json: { message: 'Invitation code is valid.', invitation_code: invitation_code }, status: 200
        else
          render json: { error: 'Invalid invitation code.' }, status: 422
        end
      end

    end
  end
end
