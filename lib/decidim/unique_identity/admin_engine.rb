# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    # This is the engine that runs on the public interface of `UniqueIdentity`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::UniqueIdentity::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :pending_authorizations, only: :index do
          resource :confirmations, only: [:new, :create], as: :confirmation
          resource :rejections, only: :create, as: :rejection
        end
        resource :offline_confirmations, only: [:new, :create], as: :offline_confirmation

        resource :config, only: [:edit, :update], controller: "config"

        root to: "pending_authorizations#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_unique_identity.assets" do
        require "decidim/extends/controllers/officializations_controller_extend"
        require "decidim/extends/controllers/confirmations_controller_extend"
      end
    end
  end
end
