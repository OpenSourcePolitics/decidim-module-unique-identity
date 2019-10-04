# frozen_string_literal: true

require "spec_helper"

describe "Identity document offline request", type: :system do
  let!(:organization) do
    create(
      :organization,
      available_authorizations: ["unique_identity"],
      unique_identity_methods: [:offline],
      unique_identity_explanation_text: { en: "This is my explanation text" }
    )
  end

  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_unique_identity.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Upload your identity document")
    expect(page).to have_content("This is my explanation text")
  end

  it "allows the user fill in her identity document" do
    fill_in "Last name", with: "El Foo"
    fill_in "First name", with: "Bar"
    fill_in "Birth date", with: "12/06/2003"
    fill_in "Birth place", with: "Dummy"

    select_gender(gender: "Male")

    check_boxes(
      city_resident: true,
      criminal_record: true,
      user_agreement: true
    )

    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      residence_doc_type: "Energy bill"
    )

    expect(page).to have_content("Document successfully uploaded")
  end

  private

  def select_gender(gender:)
    select gender, from: "Gender"
  end

  def submit_upload_form(doc_type:, doc_number:, residence_doc_type:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    select residence_doc_type, from: "Residence document type"

    click_button "Request verification"
  end

  def check_boxes(city_resident:, criminal_record:, user_agreement:)
    check "City resident" if city_resident
    check "Criminal record" if criminal_record
    check "User agreement" if user_agreement
  end
end
