# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    module Admin
      class UpdateConfig < Rectify::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_config

          broadcast(:ok)
        end

        private

        attr_reader :form

        def update_config
          Decidim.traceability.perform_action!(
            :update_unique_identity_config,
            form.current_organization,
            form.current_user
          ) do
            form.current_organization.unique_identity_methods = form.selected_methods
            form.current_organization.unique_identity_explanation_text = form.offline_explanation
            form.current_organization.save!
          end
        end
      end
    end
  end
end
