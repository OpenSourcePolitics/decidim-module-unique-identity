# Decidim::UniqueIdentity

[![CircleCI](https://circleci.com/gh/OpenSourcePolitics/decidim-module-unique-identity/tree/master.svg?style=svg)](https://circleci.com/gh/OpenSourcePolitics/decidim-module-unique-identity/tree/master)
[![Maintainability](https://api.codeclimate.com/v1/badges/2541defe5f62729ac05e/maintainability)](https://codeclimate.com/github/OpenSourcePolitics/decidim-module-unique-identity/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/2541defe5f62729ac05e/test_coverage)](https://codeclimate.com/github/OpenSourcePolitics/decidim-module-unique-identity/test_coverage)
[![Crowdin](https://badges.crowdin.net/decidim-module-unique-identity/localized.svg)](https://crowdin.com/project/decidim-module-unique-identity)

Unique identity authorization handler.

## Usage

UniqueIdentity authorization handler

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'decidim-unique_identity'
```

And then execute:

```bash
bundle
```

Apply migration:
```bash 
bundle exec rake decidim_unique_identity:install:migrations
bundle exec rake db:migrate
```

## Removing
To remove this authorization handler

Remove this line from Gemile:

```ruby
gem 'decidim-unique_identity'
```

And then execute:

```bash
bundle
bundle exec rake db:migrate SCOPE=decidim_unique_identity VERSION=0
```
You can then safely remove the file `add_unique_identity_fields_to_org.rb` from your `db/migrate` folder.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
