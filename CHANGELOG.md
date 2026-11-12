# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Per-user time zone: users can choose a time zone in their profile (`moduler_users.time_zone`, one of the `ActiveSupport::TimeZone` names, or empty for the application default from `config.time_zone`). The `Moduler::UserTimeZone` concern, included in `Moduler::ApplicationController`, runs each request in the signed-in user's time zone, so `Time.zone`, `l(...)` and `time_tag` use it; visitors who are not signed in get the application time zone. Host applications need to run `bin/rails moduler:install:migrations` and `bin/rails db:migrate`.

## [0.8.0] - 2026-11-12

### Added

- Sidebar resources in `config/moduler.yml` can require a permission: besides a name (`- reports`), a resource can be given as `- name: tasks` with `permission: tasks.read`, and is then linked from the application sidebar only for members whose role grants that permission. The permission has to be one of `permissions`; an unknown permission or a resource without a name raises `ArgumentError`. `Moduler.configuration.resources` returns the resources as `Moduler::Configuration::Resource` (`name` and `permission`, `nil` for resources every member sees), and `Moduler.configuration.administration_resources` the names of the administration resources.
- `Moduler::Current.membership`, set by `Moduler::OrganizationScoped` to the signed-in user's membership in the organization from the URL and also available as the `current_membership` helper.
- `can?(permission)` controller and view helper telling whether the role of the signed-in user in the current organization grants a permission; it is `false` outside an organization.
- `Moduler::Membership#permission?`, delegated to the membership's role.

## [0.7.0] - 2026-11-12

### Added

- Organization dashboard (`organization_path`, `/organizations/:id`) for organizations of the signed-in user; other organizations (for example after the user was removed from one) redirect to the home page with an alert. Its sidebar starts with an organization switcher: a dropdown with the current organization that lists all of the user's organizations by name and links to their dashboards, followed by a Dashboard link. The organization is kept in the URL, so every browser tab can work in a different organization.
- `Moduler::OrganizationScoped` concern for controllers nested under `/organizations/:organization_id`: it looks the organization up among the signed-in user's organizations (redirecting to the home page with an alert otherwise) and sets `Moduler::Current.organization`, also available as the `current_organization` helper.
- `dropdown` Stimulus controller closing a `<details>` dropdown on a click outside it or on Escape.

### Changed

- The application home page (`root_path`) is now a welcome page without the sidebar, listing the signed-in user's organizations by name with their role, each linking to its dashboard, or telling users without organizations to ask an administrator.
- The application sidebar is shown on organization pages only and links the `resources` from `config/moduler.yml` within the current organization (`[current_organization, resource]`, for example `organization_tasks_path`). Host applications need to nest those routes under organizations (`resources :organizations, only: [] do resources :tasks end` in the `moduler` routes block) and include `Moduler::OrganizationScoped` in their controllers.

## [0.6.0] - 2026-11-11

### Added

- `Moduler::Organization` model (`name`, required and unique) stored in a new `moduler_organizations` table with a unique index on `name`. Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Organizations page in the administration area (`administration_organizations_path`, `/administration/organizations`) listing organizations newest first and 10 per page, with their creation time. Organizations can be searched by name. Administrators can create organizations and edit their name (`Moduler::Administration::OrganizationPolicy`); organizations cannot be deleted. The page is linked from the administration sidebar.
- `permissions` in `config/moduler.yml`: the list of permissions that can be granted to organization roles (for example `tasks.read`), available as `Moduler.configuration.permissions`. Permission labels can be translated under `moduler.permissions.<permission>`; the permission itself is shown otherwise.
- `Moduler::Role` model (`name`, unique within the organization, and `permissions`, an array of permissions from `config/moduler.yml`) stored in a new `moduler_roles` table. Each organization has its own roles (`Moduler::Organization#roles`); there are no built-in roles. A role cannot be destroyed while members have it.
- `Moduler::Membership` model linking users with the member role to organizations with one of the organization's roles, stored in a new `moduler_memberships` table with a unique index on the organization and user pair. `Moduler::Organization#memberships` and `#users`, and `Moduler::User#memberships` and `#organizations` return them; destroying a user deletes their memberships. Host applications need to copy and run the new migrations (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Roles page in the administration area (`administration_roles_path`, `/administration/roles`) listing the roles of all organizations, filterable by organization and searchable by name. Administrators can create roles in a chosen organization and edit their name and permissions, choosing them from the configured ones (`Moduler::Administration::RolePolicy`); the organization cannot be changed after the role is created, and roles cannot be deleted.
- Members page in the administration area (`administration_memberships_path`, `/administration/memberships`) listing the memberships of all organizations, filterable by organization and searchable by email address. Administrators can add a user with the member role to a chosen organization with one of its roles (the role select lists the roles of the chosen organization), change a member's role and remove members (`Moduler::Administration::MembershipPolicy`); the organization and user cannot be changed.
- The roles and members pages are linked from the administration sidebar and, filtered by organization, from each organization on the organizations page.
- `OrganizationQueryFilter`, filtering like `QueryFilter` (query, page, newest first) and additionally by `organization_id`.
- `selects` option in `Moduler::FilterComponent` for additional select fields (`name`, `choices` and `prompt`); the clear link is shown when any of them is set.
- `Moduler::Form::CheckboxesComponent` (a group of checkboxes for an array attribute, with optional `label` and `description`, and the field's validation error).
- `dependent-select` Stimulus controller that repopulates a select with the choices for the value chosen in another select.
- `data` option in `Moduler::Form::SelectComponent` for data attributes of the select.
- Form components show the validation errors of a `belongs_to` association under its foreign key field (for example the "must exist" error of `user` under `moduler_user_id`).
- Optional `name` on `Moduler::User` (at most 100 characters, blank stored as `nil`), stored in a new string column `moduler_users.name`. Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`). `Moduler::User#display_name` returns the name, or the email address when the user has no name.
- Administrators can set a user's name when creating and editing users; the users list shows it and users can be searched by name. Users can set their name on the profile page.
- The header links the signed-in user's `display_name` to the profile page instead of their email address.
- `status` on `Moduler::Article` (`unpublished` or `published`, `unpublished` by default), stored in a new integer column `moduler_articles.status` (indexed, existing articles become `published`). Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`). Administrators can set the status when creating and editing articles, and the articles list shows it.
- `allow_administrator_access` for controllers that administrators may use (see Changed), and the `current_home_path` helper: the administration area for administrators, the home page for everyone else.
- `Moduler::Preference` model for runtime settings and feature toggles (`kind`: `string`, `boolean` or `integer`; `name`: unique, in constant format such as `WAITLIST`; `value`: required, `true` or `false` for a boolean and a whole number for an integer), stored in a new `moduler_preferences` table. Code reads a preference as `Moduler::Preference::NAME`, cast to its kind; a preference that does not exist reads as `nil`. Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Preferences page in the administration area (`administration_preferences_path`, `/administration/preferences`) where administrators can search preferences by name and kind, create, edit and delete them (`Moduler::Administration::PreferencePolicy`). The page is linked from the administration sidebar.
- `Moduler::Email` model for emails composed in the administration area (`subject`, optional `sender`, `kind`: `custom`, `system` or `newsletter`, optional unique `event` such as `order.paid`, Markdown `body`, `attachments` and `images`), stored in a new `moduler_emails` table. Code sends the email of an event with `Moduler::Email.deliver_event("order.paid", to: user)`, once per user and only when an email has that event; the engine sends `user.signup` after a user signs up.
- `Moduler::UserEmail` model recording which users an email has been queued for and when it was delivered (`sent_at`), stored in a new `moduler_user_emails` table with a unique index on the email and user pair. `Moduler::User#user_emails` and `#emails` return them; destroying a user or an email deletes them.
- `Moduler::SentEmail` model keeping a copy (recipient, subject, HTML body and attachments) of every email delivered by the engine's mailers, stored in a new `moduler_sent_emails` table. `Moduler::User#sent_emails` returns them; destroying a user keeps them without the user. A failure to record a copy is reported with `Rails.error` and does not fail the delivery.
- `Moduler::EmailMailer` and `Moduler::EmailDeliveryJob` delivering emails in the background. Host applications need an Active Job backend and Action Mailer delivery settings, and need to copy and run the new migrations (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Emails page in the administration area (`administration_emails_path`, `/administration/emails`) where administrators can search, compose, edit and delete emails, add attachments one file per row and remove them (removal takes effect when the email is saved), and send an email to users chosen from a list filterable by email address or name, role and whether it has been sent (`Moduler::Administration::EmailPolicy`). An email is sent to each user at most once.
- Emails page in the profile (`profile_sent_emails_path`, `/profile/sent_emails`) listing the emails delivered to the signed-in user, each viewable as delivered, with links to download its attachments.
- `Moduler::Form::AttachmentsComponent` for the files of a `has_many_attached` association: a row per attached file and an "Add attachment" button adding a row with a single file field, each row with a "Remove" button. Attached files marked for removal are submitted as `remove_<name>_ids[]` (`attachments` stimulus controller).
- `select-all` Stimulus controller for checking all checkboxes of a list.

### Changed

- The current password on the profile page is required only to change the password; other changes can be saved without it.
- The public articles list and article pages show only published articles; an unpublished article's page responds with not found.
- Images uploaded in `Moduler::Form::WysiwygComponent` are inserted with an absolute URL including the application's host (was a root-relative path), so they also work in emails. Already saved content is not changed.
- Administrators no longer use the application: they are redirected to the administration area, except on the administration area, the profile and its sessions, signing in and out, signing up and the public articles pages. Controllers of host applications that inherit from `Moduler::ApplicationController` are restricted too; call `allow_administrator_access` in those administrators may use. Signing in, the header's "Home" link and the "not authorized" redirect lead administrators to the administration area.
- The header no longer has an "Administration" link.

## [0.5.0] - 2026-11-04

### Added

- `status` on `Moduler::User` (`waitlisted`, `active` or `inactive`, `active` by default), stored in a new integer column `moduler_users.status` (indexed, existing users become `active`). Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`).
- Administrators can set a user's status when creating and editing users in the administration area.
- `Moduler::Document` model (`name`, `kind` and an attached PDF `file`, all required) stored in a new `moduler_documents` table. `kind` is one of `Moduler::Document::KINDS`: `privacy_policy`, `terms_and_conditions` or `data_processing_agreement`. The file must be a PDF under 10 MB. Host applications need to copy and run the new migrations (`bin/rails moduler:install:migrations && bin/rails db:migrate`) and have Active Storage installed.
- `Moduler::UserDocument` model linking users to documents, stored in a new `moduler_user_documents` table with a unique index on the document and user pair. `Moduler::User#user_documents` and `Moduler::User#documents` return a user's links and documents; destroying a user or a document deletes their links.
- Documents page in the administration area (`administration_documents_path`, `/administration/documents`) listing documents newest first and 10 per page, with their kind, creation time and a download link. Documents can be searched by name and kind. Administrators can create documents and edit their name and kind (`Moduler::Administration::DocumentPolicy`); the file cannot be replaced after the document is created, and documents cannot be deleted. The page is linked from the administration sidebar.
- `Moduler::Form::FileComponent` (with optional `label`, `description` and `accept`, and the field's validation error).
- Document acceptance page (`new_document_acceptance_path`, `/document_acceptance/new`) listing the documents the signed-in user has not accepted yet, oldest first, each with a checkbox and a link that opens the file in a new tab. The user must check every document; accepting them (`POST /document_acceptance`) records them and redirects to the home page. If any document is left unchecked, nothing is recorded and the page shows "Accept all documents to continue.".
- `Moduler::DocumentAcceptance` service (`Moduler::DocumentAcceptance.new(user, document_ids).call`) that validates that every pending document is among the given ids and records the acceptances, ignoring unknown and already accepted ids. It returns `true` on success, or `false` with the error in `errors`.
- `Moduler::User#pending_documents` returns the documents the user has not accepted yet.
- `skip_document_acceptance` class method for controllers that inherit from `Moduler::ApplicationController` and should stay available before the user accepts all documents (accepts the same options as `skip_before_action`).

### Changed

- Only active users can sign in. Waitlisted and inactive users who enter valid credentials see "Your account does not have access to the panel." and no session is created; an invalid password still shows "Invalid credentials".
- Existing sessions of users who are no longer active are not resumed, so changing a user's status to waitlisted or inactive signs them out on their next request.
- Signed-in users who have not accepted every document are redirected to the document acceptance page, after signing in and also whenever a new document is created. Until they accept all documents, only the profile, the profile sessions (including revoking them), signing out, the public articles and, for administrators, the administration area are available. This also applies to host application controllers that inherit from `Moduler::ApplicationController`; use `skip_document_acceptance` to keep one available.

## [0.4.0] - 2026-10-27

### Added

- `Moduler::Article` model (`path`, `title`, `description`, `keywords` and Markdown `content`, all required) stored in a new `moduler_articles` table. `path` must be unique and consist of lowercase letters, digits and hyphens. Articles can have attached `images` (PNG, JPEG, GIF or WebP, under 10 MB each). `Moduler::Article#to_html` renders the content with Redcarpet (tables and fenced code blocks) and sanitizes the result (the default safe list plus table tags). Host applications need to copy and run the new migration (`bin/rails moduler:install:migrations && bin/rails db:migrate`) and have Active Storage installed (`bin/rails active_storage:install`).
- Articles page in the administration area (`administration_articles_path`, `/administration/articles`) listing articles newest first and 10 per page. Articles can be searched by title and keywords, and administrators can create, edit and delete them (`Moduler::Administration::ArticlePolicy`). The page is linked from the administration sidebar.
- Public articles pages, available without signing in and rendered with the new `moduler/articles` layout: the list (`articles_path`, `/articles`, newest first, paginated) with each article's date, title and description, and the article page (`article_path(path)`, `/articles/:path`) with the rendered content. The article page sets the `<title>`, and the `description` and `keywords` meta tags from the article.
- `Moduler::Form::SelectComponent` (with optional `label`, `description` and `include_blank`, and the field's validation error).
- `Moduler::Form::TextareaComponent` (with optional `label` and `description`, and the field's validation error).
- `Moduler::Form::WysiwygComponent`: a Markdown editor with a toolbar (bold, italic, headings, quote, code, lists, fenced code, link and image), a live preview and Tab inserting a tab character. When the form object has the `has_many_attached` association named by the `attachments` option (`:images` by default; `attachments: false` disables it), an Upload button sends images with Active Storage direct uploads, inserts them into the content and attaches them to the record on save. The number of rows is set with `rows` (14 by default).
- Host applications can add their own resources to the administration sidebar by listing them under `administration.resources` in `config/moduler.yml`. Each resource is linked to its `administration_<resource>` route (defined e.g. with the routing DSL block) and labelled with `moduler.common.administration.sidebar.action.<resource>`.
- Sidebar on the home page with the host application's own resources, listed under `resources` in `config/moduler.yml`. Each resource is linked to its `<resource>` route in the engine (defined e.g. with the routing DSL block), labelled with `moduler.common.sidebar.action.<resource>` and highlighted while `Moduler::<Resource>Controller` is open. The sidebar is empty when no resources are configured.
- `active_storage_validations` and `redcarpet` dependencies; the engine requires `active_storage/engine`. The `marked` library (vendored) and `@rails/activestorage` are pinned in the engine's importmap.
- Tailwind Typography (`prose`) styles in the engine's stylesheet.

### Changed

- The profile sidebar partial moved from `moduler/common/sidebar` to `moduler/common/profile/sidebar`, and its translations from `moduler.common.sidebar.action.*` to `moduler.common.profile.sidebar.action.*`. Host applications that render the partial or override these translations need to use the new names; `moduler/common/sidebar` now renders the home page sidebar.

### Fixed

- The administration sidebar labels ("Users" and "Sessions") had missing translations.
- The administration area no longer fails with `NoMethodError` when `config/moduler.yml` has no `administration.resources`.

## [0.3.0] - 2026-10-25

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
- Administration search queries are limited to 100 characters; longer queries return no results.
- Users page in the administration area (`administration_users_path`, `/administration/users`) listing all users, newest first and 10 per page, with their role and creation time. Users can be searched by email address. Administrators can create users (email address, role and password) and edit other users' email address and role; they cannot edit themselves.
- Sessions page in the administration area (`administration_sessions_path`, `/administration/sessions`) listing the sessions of all users, newest first and 10 per page, with the user's email address, status (current, active or signed out), IP address, user agent and sign-in and sign-out times. Sessions can be searched by email address, IP address or user agent. Each active session can be revoked (`DELETE /administration/sessions/:id`); revoking the administrator's current session signs them out. Sessions cannot be created and there is no "Revoke all" action.
- View components for building pages: `Moduler::Administration::PageComponent` (administration layout with the sidebar), `PageHeaderComponent` (title, optional description and actions), `ButtonLinkComponent` (link styled as a button), `ButtonComponent` (`button_to` with optional `method` and `confirm`), both in default and small (`size: :sm`) sizes, `BadgeComponent` (`neutral`, `success` or `muted` variant), `FilterComponent` (search form with a clear link), `ListComponent` (list with an empty state and pagination), `ListItemComponent` (title with badges, meta and actions) and `Moduler::Form::SectionComponent` (labelled group of form fields, optionally with a divider).

### Security

- Rate limiting on sign-in and sign-up (`SessionsController#create` and `UsersController#create`, Rails' built-in `rate_limit`): at most 10 attempts per IP address and 5 attempts per email address within 3 minutes, which blocks brute force, credential stuffing and mass sign-ups. Limited users are redirected back to the form with an alert.
- Sessions now expire: a session is only resumed when `signed_in_at` is within `Moduler::Session::LIFETIME` (30 days), and the session cookie expires accordingly instead of being permanent (~20 years). A stolen cookie therefore stops working at the latest 30 days after sign-in. Sessions with no `signed_in_at` (created before this change) are never resumed, so existing users are signed out once and need to sign in again.
- Email addresses are normalized (stripped and downcased) when a user is created or signed in, so accounts differing only by case or surrounding whitespace can no longer coexist (`Jan@firma.pl`, `jan@firma.pl`, `jan@firma.pl `) and impersonating other users by email casing is not possible.
- Flash messages (including the rate-limit alert) are now also rendered for unauthenticated users; previously toasts were shown only to signed-in users, so an alert set on the sign-in or sign-up page would have been invisible.
- The session cookie is marked Secure in production (`Rails.env.production?`), so browsers only send it over HTTPS connections.

### Changed

- The sign-in and sign-up forms are built from the `Moduler::Form` components instead of hand-written markup.
- The profile form uses `Moduler::Form::SectionComponent` for its sections.
- The password confirmation placeholder on the sign-up form reads "Confirm password" (was "Password confirmation"), and the field no longer has a label.
- Passwords must be at least 8 characters long. Existing passwords keep working, and the rule applies when a password is set or changed.
- Form component labels are lighter and smaller, and the submit button is aligned to the right instead of spanning the full width.
- The engine layout fills the full height of the window.
- The header spans the full width of the window.
- Signing out redirects to the sign-in page with `303 See Other` instead of `302 Found`, so the redirect is always followed with a GET request, also under Turbo.

### Removed

- The `/hello` page with the Stimulus welcome message (its controller, view, route and Stimulus controller).

### Fixed

- Labels on the sign-in and sign-up forms now point to their inputs (`for` matches the field `id`), so clicking a label focuses its field.
- The sign-up form labels for email address and password had missing translations.
- The shared header (with the sign-out button) is rendered only for authenticated users, so it no longer appears on the sign-in and sign-up pages.
- The engine layout no longer includes the host application's `tailwind` and `application` stylesheets. Host CSS outside Tailwind's cascade layers overrode the engine's utilities and broke its pages' styles and layout.
- The engine layout sets the `viewport` meta tag, so pages use their mobile layout on phones instead of a scaled-down desktop layout.
- The header fits on narrow screens: the email address is truncated and the sign-out button no longer wraps or overflows.
- Searching sessions in the administration area by query no longer tries to match the user's name (the user has no name attribute); it matches the user's email address only.

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

[Unreleased]: https://github.com/tkowalewski/moduler/compare/0.8.0...HEAD
[0.8.0]: https://github.com/tkowalewski/moduler/compare/0.7.0...0.8.0
[0.7.0]: https://github.com/tkowalewski/moduler/compare/0.6.0...0.7.0
[0.6.0]: https://github.com/tkowalewski/moduler/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/tkowalewski/moduler/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/tkowalewski/moduler/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/tkowalewski/moduler/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/tkowalewski/moduler/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/tkowalewski/moduler/releases/tag/0.1.0
