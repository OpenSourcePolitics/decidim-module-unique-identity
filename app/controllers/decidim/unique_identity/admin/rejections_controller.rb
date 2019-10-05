# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    module Admin
      #
      # Handles rejections for verification by identity document upload.
      #
      class RejectionsController < Decidim::Admin::ApplicationController
        include UniqueIdentityComponents
        layout "decidim/admin/users"

        before_action :load_pending_authorization

        def create
          enforce_permission_to :update, :authorization, authorization: @pending_authorization

          @form = Decidim::UniqueIdentity::InformationRejectionForm.from_model(@pending_authorization)

          Decidim::Verifications::PerformAuthorizationStep.call(@pending_authorization, @form) do
            on(:ok) do
              notify_user
              flash[:notice] = t("rejections.create.success", scope: "decidim.verifications.unique_identity.admin")
              redirect_to root_path
            end
          end
        end

        private

        def load_pending_authorization
          @pending_authorization = Authorization.find(params[:pending_authorization_id])
        end

        def notify_user
          unique_id_components.each do |component|
            Decidim::EventsManager.publish(
              event: "decidim.events.unique_identity.authorization_rejected",
              event_class: Decidim::UniqueIdentity::AuthorizationRejectionEvent,
              resource: component,
              affected_users: [user]
            )
          end
        end
      end
    end
  end
end
