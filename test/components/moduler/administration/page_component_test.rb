# frozen_string_literal: true

require "test_helper"

class Moduler::Administration::PageComponentTest < ViewComponent::TestCase
  def test_renders_content_inside_main
    fragment = render_inline(Moduler::Administration::PageComponent.new) { "Page content" }

    assert_includes fragment.at_css("main")&.text, "Page content"
  end

  def test_renders_administration_sidebar
    fragment = render_inline(Moduler::Administration::PageComponent.new) { "Page content" }

    assert_not_empty fragment.css("main aside a[href='/application/administration/users']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/sessions']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/articles']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/documents']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/preferences']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/emails']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/organizations']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/roles']")
    assert_not_empty fragment.css("main aside a[href='/application/administration/memberships']")
  end
end
