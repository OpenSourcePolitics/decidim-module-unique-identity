# frozen_string_literal: true

require "spec_helper"

describe "Identity document online upload", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ["unique_identity"])
  end

  let!(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_unique_identity.root_path
  end

  it "redirects to verification after login" do
    expect(page).to have_content("Upload your identity document")
  end

  it "allows the user to upload her identity document" do
    fill_in "Last name", with: "El Foo"
    fill_in "First name", with: "Bar"
    fill_in "Birth date", with: "12/06/2003"
    fill_in "Birth place", with: "Dummy"
    select_gender(gender: "Female")

    check_boxes(
      city_resident: true,
      criminal_record: true,
      user_agreement: true,
      not_a_member: true
    )

    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      residence_doc_type: "Energy bill",
      file_name: "id.jpg"
    )

    expect(page).to have_content("Document successfully uploaded")
  end

  it "shows an error when upload failed" do
    fill_in "Last name", with: "El Foo"
    fill_in "First name", with: "Bar"
    fill_in "Birth date", with: "12/06/2003"
    fill_in "Birth place", with: "Dummy"
    select_gender(gender: "Female")

    check_boxes(
      city_resident: true,
      criminal_record: true,
      user_agreement: true,
      not_a_member: true
    )

    submit_upload_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      residence_doc_type: "Energy bill",
      file_name: "Exampledocument.pdf"
    )

    expect(page).to have_content("There was a problem uploading your document")
  end

  private

  def select_gender(gender:)
    select gender, from: "Gender"
  end

  def check_boxes(city_resident:, criminal_record:, user_agreement:, not_a_member:)
    check "City resident" if city_resident
    check "Criminal record" if criminal_record
    check "User agreement" if user_agreement
    check "I am not a member of a political party or movement" if not_a_member
  end

  def submit_upload_form(doc_type:, doc_number:, residence_doc_type:, file_name:)
    select doc_type, from: "Type of your document"
    fill_in "Document number (with letter)", with: doc_number
    select residence_doc_type, from: "Residence document type"
    attach_file "Scanned copy of your document", Decidim::Dev.asset(file_name)

    click_button "Request verification"
  end
end
