# frozen_string_literal: true

require "test_helper"

class Moduler::BadgeComponentTest < ViewComponent::TestCase
  def test_renders_text
    fragment = render_inline(Moduler::BadgeComponent.new("Member"))

    assert_equal "Member", fragment.at_css("span")&.text&.strip
  end

  def test_renders_neutral_variant_by_default
    fragment = render_inline(Moduler::BadgeComponent.new("Member"))

    assert_not_empty fragment.css("span.bg-slate-50.text-slate-600")
  end

  def test_renders_success_variant
    fragment = render_inline(Moduler::BadgeComponent.new("Administrator", variant: :success))

    assert_not_empty fragment.css("span.bg-emerald-50.text-emerald-700")
  end

  def test_renders_muted_variant
    fragment = render_inline(Moduler::BadgeComponent.new("Signed out", variant: :muted))

    assert_not_empty fragment.css("span.text-slate-400")
    assert_empty fragment.css("span.bg-slate-50")
  end
end
