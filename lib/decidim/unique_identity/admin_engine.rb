# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    # This is the engine that runs on the public interface of `UniqueIdentity`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::UniqueIdentity::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :unique_identity do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "unique_identity#index"
      end

      def load_seed
        nil
      end
    end
  end
end
