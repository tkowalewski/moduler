module Moduler
  # An email composed in the administration area and sent to chosen users,
  # or from code by its event name:
  #
  #   Moduler::Email.deliver_event("order.paid", to: user)
  #
  # The engine itself sends "user.signup" after a user signs up.
  class Email < ApplicationRecord
    include PgSearch::Model

    KINDS = %w[ custom system newsletter ].freeze
    EVENT_FORMAT = /\A[a-z0-9_]+(\.[a-z0-9_]+)*\z/

    has_many :user_emails, class_name: "Moduler::UserEmail", foreign_key: "moduler_email_id", dependent: :destroy

    has_many_attached :attachments
    has_many_attached :images

    normalizes :event, with: ->(event) { event.strip.presence }
    normalizes :sender, with: ->(sender) { sender.strip.presence }

    validates :subject, presence: true
    validates :kind, presence: true, inclusion: { in: KINDS }
    validates :event, uniqueness: true, format: { with: EVENT_FORMAT }, allow_nil: true
    validates :body, presence: true
    validates :images, content_type: %w[ image/png image/jpeg image/gif image/webp ], size: { less_than: 10.megabytes }

    pg_search_scope :search_by_query, against: %i[ subject kind ], using: { trigram: { word_similarity: true } }

    # Sends the email of the given event to the user, once. Does nothing
    # when no email has the event.
    def self.deliver_event(event, to:)
      find_by(event: event.to_s)&.deliver_to([ to ])
    end

    # Queues the email for the users it has not been queued for yet and
    # returns how many were queued.
    def deliver_to(users)
      users.count do |user|
        user_email = user_emails.find_or_create_by!(user: user)
        next false unless user_email.previously_new_record?

        EmailDeliveryJob.perform_later(user_email)
        true
      end
    end

    # The number of users the email has been delivered to.
    def sent_count
      user_emails.sent.count
    end

    def to_html
      html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, tables: true, fenced_code_blocks: true).render(body.to_s)

      ActionController::Base.helpers.sanitize(html, tags: Moduler::Article::ALLOWED_TAGS)
    end
  end
end
