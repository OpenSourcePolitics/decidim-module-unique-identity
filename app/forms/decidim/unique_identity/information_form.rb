# frozen_string_literal: true

module Decidim
  module UniqueIdentity
    # A form object to be used as the base for identity document verification
    class InformationForm < AuthorizationHandler
      mimic :unique_identity_information

      DOCUMENT_TYPES = %w(DNI home_insurance_attestation passport).freeze
      RESIDENCE_DOCUMENT_TYPES = %w(fix_phone_bill internet_bill energy_bill).freeze
      GENDER_TYPES = %w(male female).freeze

      attribute :last_name, String
      attribute :first_name, String
      attribute :birth_date, Date
      attribute :gender, String
      attribute :birth_place, String
      attribute :document_number, String
      attribute :document_type, String
      attribute :residence_document_type, String
      attribute :verification_type, String
      attribute :city_resident, Boolean
      attribute :criminal_record, Boolean
      attribute :user_agreement, Boolean

      validates :last_name, :first_name, :birth_date, :birth_place, presence: true

      validates :city_resident, :criminal_record, :user_agreement, :not_a_member, acceptance: true

      validate :birth_date_is_of_date_type

      validates :gender,
                inclusion: { in: GENDER_TYPES },
                presence: true

      validates :document_type,
                inclusion: { in: DOCUMENT_TYPES },
                presence: true

      validates :residence_document_type,
                inclusion: { in: RESIDENCE_DOCUMENT_TYPES },
                presence: true

      validates :document_number,
                format: { with: /\A[A-Z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") },
                presence: true

      validates :verification_type,
                presence: true,
                inclusion: { in: %w(offline online) }

      def handler_name
        "unique_identity"
      end

      def unique_id
        return unless birth_date.is_a? Date

        ln = last_name.tr(" ", "-")
        fn = first_name
        ge = gender
        bd = birth_date.strftime("%d-%m-%Y")
        bp = birth_place.tr(" ", "-")

        "#{ln}_#{fn}_#{ge}_#{bd}_#{bp}".upcase
      end

      def map_model(model)
        self.document_type = model.verification_metadata["document_type"]
        self.residence_document_type = model.verification_metadata["residence_document_type"]
        self.document_number = model.verification_metadata["document_number"]
        self.gender = model.verification_metadata["gender"]
        self.city_resident = model.verification_metadata["city_resident"]
        self.verification_type = model.verification_metadata["verification_type"].presence || "online"
        self.last_name = model.verification_metadata["last_name"]
        self.first_name = model.verification_metadata["first_name"]
        self.birth_date = model.verification_metadata["birth_date"]
        self.birth_place = model.verification_metadata["birth_place"]
      end

      def verification_metadata
        {
          "document_type" => document_type,
          "residence_document_type" => residence_document_type,
          "gender" => gender,
          "document_number" => document_number.upcase,
          "city_resident" => city_resident,
          "verification_type" => verification_type,
          "last_name" => last_name.upcase,
          "first_name" => first_name.upcase,
          "birth_date" => birth_date.strftime("%d-%m-%Y"),
          "birth_place" => birth_place.upcase
        }
      end

      def document_types_for_select
        DOCUMENT_TYPES.map do |type|
          [
            I18n.t(type.downcase, scope: "decidim.verifications.unique_identity.type"),
            type
          ]
        end
      end

      def residence_document_types_for_select
        RESIDENCE_DOCUMENT_TYPES.map do |type|
          [
            I18n.t(type.downcase, scope: "decidim.verifications.unique_identity.type"),
            type
          ]
        end
      end

      def gender_types_for_select
        GENDER_TYPES.map do |type|
          [
            I18n.t(type.downcase, scope: "decidim.verifications.unique_identity.gender"),
            type
          ]
        end
      end

      def uses_online_method?
        verification_type == "online"
      end

      def birth_date_is_of_date_type
        errors.add(:birth_date, I18n.t("errors.messages.date_format")) unless birth_date.is_a? Date
      end
    end
  end
end
