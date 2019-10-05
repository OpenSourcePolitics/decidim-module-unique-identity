# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    module Admin
      #
      # Handles confirmations for verification by identity document upload.
      #
      class ConfirmationsController < Decidim::Admin::ApplicationController
        include UniqueIdentityComponents
        layout "decidim/admin/users"

        before_action :load_pending_authorization

        def new
          enforce_permission_to :update, :authorization, authorization: @pending_authorization

          @form = InformationForm.from_model(@pending_authorization)
        end

        def create
          enforce_permission_to :update, :authorization, authorization: @pending_authorization

          @form = InformationForm.from_params(params.merge(user: @pending_authorization.user))

          Decidim::Verifications::ConfirmUserAuthorization.call(@pending_authorization, @form) do
            on(:ok) do
              notify_user
              flash[:notice] = t("confirmations.create.success", scope: "decidim.verifications.unique_identity.admin")
              redirect_to pending_authorizations_path
            end

            on(:invalid) do
              flash.now[:alert] = t("confirmations.create.error", scope: "decidim.verifications.unique_identity.admin")
              render action: :new
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
                event: "decidim.events.unique_identity.authorization_accepted",
                event_class: Decidim::UniqueIdentity::AuthorizationAcceptionEvent,
                resource: component,
                affected_users: [user]
            )
          end
        end
      end
    end
  end
end
