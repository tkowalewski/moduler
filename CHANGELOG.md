# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `view_component` dependency and form components in `Moduler::Form`: `TextComponent`, `EmailComponent`, `PasswordComponent` (all three with optional `label`, `placeholder` and `description`, and the field's validation error), `SubmitComponent` (with optional `text`) and `BaseErrorComponent` (renders the form's first `:base` error).
- The sign-up form shows `:base` errors and a password hint ("Use at least 8 characters containing at least 1 number and 1 lowercase letter").
- `role` on `Moduler::User` (`member` or `administrator`), stored in a new integer column `moduler_users.role`. Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Profile page (`edit_profile_path`, `/profile/edit`) where a signed-in user can change their password. The current password is required, and changing the password signs out the user's other active sessions. The email address is shown but cannot be changed.
- The header shows the signed-in user's email address, linked to the profile page.
- Flash messages are shown as toasts in the top-right corner for signed-in users. They close after 5 seconds or with the close button.
- `current_user` helper in controllers and views.
- `Moduler::Session.active` scope (sessions that are not signed out).
- `disabled` option for `Moduler::Form::EmailComponent`.
- Sessions page (`profile_sessions_path`, `/profile/sessions`) listing the signed-in user's sessions, newest first and 20 per page, with sign-in time, IP address, user agent and status (current, active or signed out). Each active session can be revoked. Revoking the current session signs the user out.
- "Revoke all sessions" button on the sessions page that signs out every active session of the user, including the current one. It sends `DELETE /profile/sessions/revocation` (`profile_sessions_revocation_path`), handled by `Moduler::Profile::Sessions::RevocationController#destroy`.
- `turbo-rails` dependency. The engine's JavaScript loads Turbo, so revoking a session or all sessions asks for confirmation first.
- Sidebar on the profile and sessions pages with links between them, built from the new `Moduler::SidebarActionComponent` (highlights the link of the current controller). On small screens it is shown as a horizontal bar above the content.
- `kaminari` dependency, with Tailwind-styled pagination views.
- `Moduler::Session#active?`.
- `pundit` dependency. `Moduler::ApplicationController` includes `Pundit::Authorization`, and `Moduler::ApplicationPolicy` denies everything by default.
- Per-controller policies for the administration area (`Moduler::Administration::HomePolicy`, `UserPolicy` and `SessionPolicy`, all built on `Administration::BasePolicy`), each action authorized against its own policy method. Only administrators are allowed for now, so members and guests can no longer open the administration area: unauthorized users are redirected to the home page with an alert. The administration link in the header is rendered based on the same policies instead of a direct role check.

### Security

- Rate limiting on sign-in and sign-up (`SessionsController#create` and `UsersController#create`, Rails' built-in `rate_limit`): at most 10 attempts per IP address and 5 attempts per email address within 3 minutes, which blocks brute force, credential stuffing and mass sign-ups. Limited users are redirected back to the form with an alert.
- Sessions now expire: a session is only resumed when `signed_in_at` is within `Moduler::Session::LIFETIME` (30 days), and the session cookie expires accordingly instead of being permanent (~20 years). A stolen cookie therefore stops working at the latest 30 days after sign-in. Sessions with no `signed_in_at` (created before this change) are never resumed, so existing users are signed out once and need to sign in again.
- Flash messages (including the rate-limit alert) are now also rendered for unauthenticated users; previously toasts were shown only to signed-in users, so an alert set on the sign-in or sign-up page would have been invisible.

### Changed

- The sign-in and sign-up forms are built from the `Moduler::Form` components instead of hand-written markup.
- The password confirmation placeholder on the sign-up form reads "Confirm password" (was "Password confirmation"), and the field no longer has a label.
- Passwords must be at least 8 characters long. Existing passwords keep working, and the rule applies when a password is set or changed.
- Form component labels are lighter and smaller, and the submit button is aligned to the right instead of spanning the full width.
- The engine layout fills the full height of the window.
- The header spans the full width of the window.
- Signing out redirects to the sign-in page with `303 See Other` instead of `302 Found`, so the redirect is always followed with a GET request, also under Turbo.

### Fixed

- Labels on the sign-in and sign-up forms now point to their inputs (`for` matches the field `id`), so clicking a label focuses its field.
- The sign-up form labels for email address and password had missing translations.
- The shared header (with the sign-out button) is rendered only for authenticated users, so it no longer appears on the sign-in and sign-up pages.
- The engine layout no longer includes the host application's `tailwind` and `application` stylesheets. Host CSS outside Tailwind's cascade layers overrode the engine's utilities and broke its pages' styles and layout.
- The engine layout sets the `viewport` meta tag, so pages use their mobile layout on phones instead of a scaled-down desktop layout.
- The header fits on narrow screens: the email address is truncated and the sign-out button no longer wraps or overflows.

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
