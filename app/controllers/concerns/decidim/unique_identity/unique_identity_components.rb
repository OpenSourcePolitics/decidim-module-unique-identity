# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    module UniqueIdentityComponents
      private

      def user
        @pending_authorization.user
      end

      def unique_id_components
        Decidim::Component.where.not(permissions: nil).select do |component|
          component.permissions.any? do |_key, value|
            value["authorization_handlers"].any? do |key, _value|
              key == "unique_identity"
            end
          end
        end
      end
    end
  end
end
