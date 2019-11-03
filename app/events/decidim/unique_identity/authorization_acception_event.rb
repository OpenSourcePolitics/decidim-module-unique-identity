# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    class AuthorizationAcceptionEvent < Decidim::Events::SimpleEvent
      i18n_attributes :participatory_space_title

      def participatory_space_title
        @participatory_space_title ||= translated_attribute(resource.participatory_space.title)
      end

      def resource_url
        return super unless resource.is_a?(Decidim::Component)

        @resource_url ||= [main_component_url(resource), resource.manifest, "new"].join("/")
      end
    end
  end
end
