# frozen_string_literal: true

Decidim::Verifications.register_workflow(:unique_identity) do |workflow|
  workflow.engine = Decidim::UniqueIdentity::Engine
  workflow.admin_engine = Decidim::UniqueIdentity::AdminEngine
end
