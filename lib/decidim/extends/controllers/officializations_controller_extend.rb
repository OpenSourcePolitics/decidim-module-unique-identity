# frozen_string_literal: true

require "active_support/concern"

module OfficializationsControllerExtend
  extend ActiveSupport::Concern

  def unique_id(user)
    authorizations.find_by(user: user).try(:unique_id)
  end

  def authorizations
    @authorizations = Decidim::Verifications::Authorizations.new(organization: current_organization, name: "unique_identity").query
  end
end

Decidim::Admin::OfficializationsController.class_eval do
  prepend(OfficializationsControllerExtend)

  helper_method :unique_id
  delegate :unique_id, to: :user
end
