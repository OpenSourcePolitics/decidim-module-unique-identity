# frozen_string_literal: true

require "spec_helper"

describe "Identity document offline review", type: :system do
  let!(:organization) do
    create(
      :organization,
      available_authorizations: ["unique_identity"],
      unique_identity_methods: ["offline"],
      unique_identity_explanation_text: { en: "Foobar" }
    )
  end

  let(:user) { create(:user, :confirmed, organization: organization) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      id: 1,
      name: "unique_identity",
      user: user,
      verification_metadata: {
        "verification_type" => "offline",
        "document_type" => "DNI",
        "document_number" => "XXXXXXXX",
        "last_name" => "EL FAMOSO",
        "first_name" => "ARMANDO",
        "birth_date" => "15-12-1998",
        "birth_place" => "PARIS",
        "residence_document_type" => "energy_bill",
        "city_resident" => true
      }
    )
  end

  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_unique_identity.root_path
    click_link "Offline verification"
  end

  it "allows the user to verify an identity document" do
    fill_in "Last name", with: "El Famoso"
    fill_in "First name", with: "Armando"
    fill_in "Birth date", with: "15/12/1998"
    fill_in "Birth place", with: "Paris"

    check_boxes(
      city_resident: true,
      criminal_record: false,
      user_agreement: false
    )

    submit_verification_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      residence_doc_type: "Energy bill"
    )

    expect(page).to have_content("Participant successfully verified")
  end

  it "shows an error when there's no authorization for the given email" do
    fill_in "Last name", with: "El Foo"
    fill_in "First name", with: "Bar"
    fill_in "Birth date", with: "12/06/2003"
    fill_in "Birth place", with: "Dummy"

    check_boxes(
      city_resident: true,
      criminal_record: false,
      user_agreement: false
    )

    submit_verification_form(
      doc_type: "DNI",
      doc_number: "XXXXXXXX",
      residence_doc_type: "Energy bill",
      user_email: "this@doesnt.exist"
    )

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("INTRODUCE THE PARTICIPANT EMAIL AND THE DOCUMENT DATA")
  end

  it "shows an error when information doesn't match" do
    fill_in "Last name", with: "El Foo"
    fill_in "First name", with: "Bar"
    fill_in "Birth date", with: "12/06/2003"
    fill_in "Birth place", with: "Dummy"

    check_boxes(
      city_resident: true,
      criminal_record: false,
      user_agreement: false
    )

    submit_verification_form(
      doc_type: "NIE",
      doc_number: "XXXXXXXY",
      residence_doc_type: "Energy bill"
    )

    expect(page).to have_content("Verification doesn't match")
    expect(page).to have_content("INTRODUCE THE PARTICIPANT EMAIL AND THE DOCUMENT DATA")
  end

  private

  def check_boxes(city_resident:, criminal_record:, user_agreement:)
    check "City resident" if city_resident
    check "Criminal record" if criminal_record
    check "User agreement" if user_agreement
  end

  def submit_verification_form(doc_type:, doc_number:, residence_doc_type:, user_email: user.email)
    fill_in "Participant email", with: user_email
    select doc_type, from: "Type of the document"
    fill_in "Document number (with letter)", with: doc_number
    select residence_doc_type, from: "Residence document type"

    click_button "Verify"
  end
end
