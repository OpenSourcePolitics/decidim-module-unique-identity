# frozen_string_literal: true

require "spec_helper"

module Decidim::UniqueIdentity
  describe InformationForm do
    subject do
      described_class.new(
        user: user,
        verification_type: verification_type,
        document_type: document_type,
        document_number: document_number,
        last_name: last_name,
        gender: gender,
        first_name: first_name,
        birth_date: birth_date,
        birth_place: birth_place,
        residence_document_type: residence_document_type,
        city_resident: city_resident,
        criminal_record: criminal_record,
        user_agreement: user_agreement,
        not_a_member: not_a_member
      )
    end

    let(:user) { create(:user) }

    let(:last_name) { "El Foo" }
    let(:first_name) { "Bar" }
    let(:birth_date) { "12/06/2003" }
    let(:birth_place) { "Dummy 23" }
    let(:gender) { "female" }
    let(:verification_type) { "online" }
    let(:document_type) { "DNI" }
    let(:document_number) { "XXXXXXXXY" }
    let(:residence_document_type) { "energy_bill" }
    let(:city_resident) { true }
    let(:criminal_record) { true }
    let(:user_agreement) { true }
    let(:not_a_member) { true }

    context "when the information is valid" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "return a unique id" do
        expect(subject.unique_id).to eq("EL-FOO_BAR_FEMALE_12-06-2003_DUMMY-23")
      end
    end

    context "when verification type is invalid" do
      let(:verification_type) { "invalid type" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:verification_type]).to include("is not included in the list")
      end
    end

    context "when document type is invalid" do
      let(:document_type) { "driver's license" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:document_type]).to include("is not included in the list")
      end
    end

    context "when the document format is invalid" do
      let(:document_number) { "XXXXXXXX-Y" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:document_number])
          .to include("must be all uppercase and contain only letters and/or numbers")
      end
    end

    context "when the residence document type is invalid" do
      let(:residence_document_type) { "mobile_phone_bill" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:residence_document_type]).to include("is not included in the list")
      end
    end

    context "when the gender is invalid" do
      let(:gender) { "other" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:gender]).to include("is not included in the list")
      end
    end

    context "when city resident is not true" do
      let(:city_resident) { false }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "when not a member is not true" do
      let(:not_a_member) { false }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "when criminal record is not true" do
      let(:criminal_record) { false }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "when user agreement is not true" do
      let(:user_agreement) { false }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end

    context "when birth_date is not a date" do
      let(:birth_date) { "Foobar" }

      it "is not valid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:birth_date])
          .to include("must be on date format: dd/mm/yyyy")
      end
    end
  end
end
