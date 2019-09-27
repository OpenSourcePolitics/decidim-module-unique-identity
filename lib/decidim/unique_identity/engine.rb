# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module UniqueIdentity
    # This is the engine that runs on the public interface of unique_identity.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::UniqueIdentity

      routes do
        resource :authorizations, only: [:new, :create, :edit, :update], as: :authorization do
          collection do
            get :choose
          end
        end

        root to: "authorizations#choose"
      end

      initializer "decidim_unique_identity.assets" do |app|
        app.config.assets.precompile += %w[decidim_unique_identity_manifest.js decidim_unique_identity_manifest.css]
      end
    end
  end
end
