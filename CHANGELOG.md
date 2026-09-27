# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- The shared header (with the sign-out button) is rendered only for authenticated users, so it no longer appears on the sign-in and sign-up pages.

## [0.2.0] - 2026-09-27

### Added

- Routing DSL for host applications: `moduler "/path"` mounts the engine at the given path, and an optional block adds routes inside the engine's route set:

  ```ruby
  Rails.application.routes.draw do
    moduler "/application" do
      get "/reports", to: "reports#index"
    end
  end
  ```

- Shared header (`moduler/common/header`) in the engine layout with a link to the home page and a sign-out button.
- The engine layout includes the host application's `tailwind` and `application` stylesheets when they exist (`stylesheet_link_tags_if_exist` helper).
- `Procfile` for running the dummy application with foreman.

### Changed

- The Stimulus welcome message moved from the root page to `/hello`; the root page (`HomeController`) is now the home page for signed-in users.
- Stimulus controllers live in `app/assets/javascripts/moduler/controllers` and are eager-loaded by the `moduler/application` entry point.

### Fixed

- JavaScript failed to load in the host application (`Module name, 'application' does not resolve to a valid URL`): the engine now has its own importmap entry point and pins Stimulus.

## [0.1.0] - 2026-03-25

### Added

- Rails engine skeleton (`Moduler::Engine`, isolated namespace) with a dummy application for development and tests.
- User registration and sign in/sign out:
  - `Moduler::User` (`has_secure_password`) and `Moduler::Session` models with UUID primary keys; sessions track IP address, user agent and sign-in/sign-out timestamps.
  - `Moduler::Authentication` concern with `allow_unauthenticated_access` and the `authenticated?` helper.
  - `UsersController` (`/user/new`) and `SessionsController` (`/session/new`) with English translations.
  - `Moduler::FormBuilder` with `error`, `full_error` and `error?` helpers.
- Root page with a Stimulus welcome message.
- Engine configuration loaded from the host's `config/moduler.yml` (`Moduler.configuration`).
- JavaScript via importmap-rails and Stimulus.
- Tailwind CSS build for the engine (`app:moduler:tailwindcss:build` and `app:moduler:tailwindcss:watch` tasks).
- `docker-compose.yml` for PostgreSQL.

[Unreleased]: https://github.com/tkowalewski/moduler/compare/0.2.0...HEAD
[0.2.0]: https://github.com/tkowalewski/moduler/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/tkowalewski/moduler/releases/tag/0.1.0
