# frozen_string_literal: true

require "spec_helper"

describe "Identity document online review", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["unique_identity"])
  end

  let!(:component) { create(:dummy_component) }

  let(:user) { create(:user, :confirmed, organization: organization) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      id: 1,
      name: "unique_identity",
      user: user,
      verification_metadata: {
        "verification_type" => "online",
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX",
        "last_name" => "PETIT",
        "first_name" => "JEAN",
        "gender" => "male",
        "birth_date" => "02-08-1986",
        "birth_place" => "MARSEILLE",
        "residence_document_type" => "energy_bill",
        "city_resident" => true
      },
      verification_attachment: Decidim::Dev.test_file("id.jpg", "image/jpg")
    )
  end

  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_unique_identity.root_path
    click_link "Verification #1"
  end

  it "displays user infos" do
    expect(page).to have_content("PETIT")
    expect(page).to have_content("JEAN")
    expect(page).to have_content("Male")
    expect(page).to have_content("MARSEILLE")
    expect(page).to have_content("02/08/1986")
    expect(page).to have_content("DNI")
    expect(page).to have_content("XXXXXXXX")
    expect(page).to have_content("Energy bill")
    expect(page).to have_content("City resident")
  end

  it "allows the user to verify an identity document" do
    click_button "Verify"

    expect(page).to have_content("Participant successfully verified")
    expect(page).to have_no_content("Verification #")

    relogin_as user, scope: :user
    visit decidim.notifications_path

    expect(page).to have_no_content("Your authorization application has been accepted")
  end

  context "when rejected" do
    before { click_link "Reject" }

    it "dismisses the verification from the list" do
      expect(page).to have_content("Verification rejected. Participant will be prompted to amend her documents")
      expect(page).to have_no_content("Verification #")
    end

    context "and the user logs back in" do
      before do
        relogin_as user, scope: :user
        visit decidim_verifications.authorizations_path
        click_link "Unique identity"
      end

      it "displays a rejectance notification" do
        relogin_as user, scope: :user
        visit decidim.notifications_path

        expect(page).to have_no_content("Your authorization application has been rejected")
      end

      it "allows the user to change the uploaded documents" do
        expect(page).to have_selector("form", text: "Request verification again")
      end

      it "allows the verificator to review the amended request" do
        fill_in "Last name", with: "Petit"
        fill_in "First name", with: "Jean"
        fill_in "Birth date", with: "02/08/1986"
        fill_in "Birth place", with: "Marseille"
        select_gender(gender: "Male")

        check_boxes(
          city_resident: true,
          criminal_record: true,
          user_agreement: true
        )

        submit_reupload_form(
          doc_type: "DNI",
          doc_number: "XXXXXXXY",
          file_name: "dni.jpg",
          residence_doc_type: "Energy bill"
        )
        expect(page).to have_content("Document successfully reuploaded")

        relogin_as admin, scope: :user
        visit decidim_admin_unique_identity.root_path
        click_link "Verification #1"

        expect(page).to have_css("img[src*='dni.jpg']")
        click_button "Verify"
        expect(page).to have_content("Participant successfully verified")
      end

      it "shows an informative message to the user" do
        expect(page).to have_content("There was a problem with your verification. Please try again")
        expect(page).to have_content("Make sure the information entered is correct")
        expect(page).to have_content("Make sure the information is clearly visible in the uploaded image")
      end
    end
  end

  private

  def select_gender(gender:)
    select gender, from: "Gender"
  end

  def check_boxes(city_resident:, criminal_record:, user_agreement:)
    check "City resident" if city_resident
    check "Criminal record" if criminal_record
    check "User agreement" if user_agreement
  end

  def submit_reupload_form(doc_type:, doc_number:, residence_doc_type:, file_name:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    select residence_doc_type, from: "Residence document type"
    attach_file "Scanned copy of your document", Decidim::Dev.asset(file_name)

    click_button "Request verification again"
  end
end
