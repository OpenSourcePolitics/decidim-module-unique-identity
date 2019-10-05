# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe AccountForm do
    subject do
      described_class.new(
          name: name,
          email: email,
          nickname: nickname,
          password: password,
          phone: phone,
          password_confirmation: password_confirmation,
          avatar: avatar,
          remove_avatar: remove_avatar,
          personal_url: personal_url,
          about: about
      ).with_context(
          current_organization: organization,
          current_user: user
      )
    end

    let(:user) { create(:user) }
    let(:organization) { user.organization }

    let(:name) { "Lord of the Foo" }
    let(:email) { "depths@ofthe.bar" }
    let(:nickname) { "foo_bar" }
    let(:phone) { "0612686945" }
    let(:password) { "Rf9kWTqQfyqkwseH" }
    let(:password_confirmation) { password }
    let(:avatar) { File.open("spec/assets/avatar.jpg") }
    let(:remove_avatar) { false }
    let(:personal_url) { "http://example.org" }
    let(:about) { "This is a description about me" }

    context "with correct data" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "with an empty name" do
      let(:name) { "" }

      it "is invalid" do
        expect(subject).not_to be_valid
      end
    end

    describe "email" do
      context "with an empty email" do
        let(:email) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in the same organization" do
        let!(:existing_user) { create(:user, email: email, organization: organization) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, email: email) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    describe "nickname" do
      context "with an empty nickname" do
        let(:nickname) { "" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in the same organization" do
        let!(:existing_user) { create(:user, nickname: nickname, organization: organization) }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end

      context "when it's already in use in another organization" do
        let!(:existing_user) { create(:user, nickname: nickname) }

        it "is valid" do
          expect(subject).to be_valid
        end
      end
    end

    describe "password" do
      context "when the password is weak" do
        let(:password) { "aaaabbbbcccc" }

        it { is_expected.to be_invalid }
      end
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


    describe "personal_url" do
      context "when it doesn't start with http" do
        let(:personal_url) { "example.org" }

        it "adds it" do
          expect(subject.personal_url).to eq("http://example.org")
        end
      end

      context "when it's not a valid URL" do
        let(:personal_url) { "foobar, aa" }

        it "is invalid" do
          expect(subject).not_to be_valid
        end
      end
    end
  end
end
