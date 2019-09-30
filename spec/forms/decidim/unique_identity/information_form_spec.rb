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
          first_name: first_name,
          birth_date: birth_date,
          birth_place: birth_place
      )
    end

    let(:user) { create(:user) }

    let(:last_name) { "El Foo" }
    let(:first_name) { "Bar" }
    let(:birth_date) { "12/06/2003" }
    let(:birth_place) { "Dummy 23" }
    let(:verification_type) { "online" }
    let(:document_type) { "DNI" }
    let(:document_number) { "XXXXXXXXY" }

    context "when the information is valid" do
      it "is valid" do
        expect(subject).to be_valid
      end

      it "return a unique id" do
        expect(subject.unique_id).to eq("EL-FOO_BAR_12-06-2003_DUMMY-23")
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
