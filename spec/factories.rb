# frozen_string_literal: true

require "decidim/unique_identity/test/factories"

FactoryBot.modify do
  factory :user, class: "Decidim::User" do
    email { generate(:email) }
    password { "password1234" }
    password_confirmation { password }
    name { generate(:name) }
    phone { "0#{(0..9).to_a.sample(9).shuffle.join}" }
    nickname { generate(:nickname) }
    organization
    locale { organization.default_locale }
    tos_agreement { "1" }
    avatar { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    personal_url { Faker::Internet.url }
    about { "<script>alert(\"ABOUT\");</script>" + Faker::Lorem.paragraph(2) }
    confirmation_sent_at { Time.current }
    accepted_tos_version { organization.tos_version }
    email_on_notification { true }

    trait :confirmed do
      confirmed_at { Time.current }
    end

    trait :deleted do
      email { "" }
      deleted_at { Time.current }
    end

    trait :admin do
      admin { true }
    end

    trait :user_manager do
      roles { ["user_manager"] }
    end

    trait :managed do
      email { "" }
      password { "" }
      password_confirmation { "" }
      encrypted_password { "" }
      managed { true }
    end

    trait :officialized do
      officialized_at { Time.current }
      officialized_as { generate_localized_title }
    end
  end
end
