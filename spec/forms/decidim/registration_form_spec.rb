# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "User" }
    let(:nickname) { "justme" }
    let(:phone) { "0657654321" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:password_confirmation) { password }
    let(:tos_agreement) { "1" }

    let(:attributes) do
      {
        name: name,
        nickname: nickname,
        email: email,
        phone: phone,
        password: password,
        password_confirmation: password_confirmation,
        tos_agreement: tos_agreement
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.to be_invalid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the nickname is not present" do
      let(:nickname) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email already exists" do
      let!(:user) { create(:user, organization: organization, email: email) }

      it { is_expected.to be_invalid }
    end

    context "when the nickname already exists" do
      let!(:user) { create(:user, organization: organization, nickname: nickname) }

      it { is_expected.to be_invalid }
    end

    context "when the nickname is too long" do
      let(:nickname) { "verylongnicknamethatcreatesanerror" }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is not present" do
      let(:password_confirmation) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
    end

    describe "phone" do
      context "when not provided" do
        let(:phone) { nil }

        it { is_expected.to be_valid }
      end

      context "when it doesn't start by 0" do
        let(:phone) { "2233445566" }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:phone])
            .to include("Must contains only ten digits and starts by zero")
        end
      end

      context "when it doesn't contains only digits" do
        let(:phone) { "06500542A" }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:phone])
            .to include("Must contains only ten digits and starts by zero")
        end
      end

      context "when it exceeds 10 digits" do
        let(:phone) { "22334455667" }

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:phone])
            .to include("Must contains only ten digits and starts by zero")
        end
      end
    end
  end
end
