# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    # A form object to be used as the base for identity document verification
    module Admin
      class OfflineConfirmationForm < InformationForm
        attribute :email, String

        def unique_id
          super if user
        end

        def user
          Decidim::User
              .where(organization: current_organization)
              .find_by(email: email)
        end
      end
    end
  end
end
