# frozen_string_literal: true

require "test_helper"

class Moduler::SidebarActionComponentTest < ViewComponent::TestCase
  def test_renders_link_with_action_and_route
    fragment = render_inline(Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "moduler/profile"))

    assert_equal "Profile", fragment.at_css("a[href='/application/profile/edit']")&.text&.strip
  end

  def test_renders_single_link
    fragment = render_inline(Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "moduler/profile"))

    assert_equal 1, fragment.css("a").size
  end

  def test_renders_active_link_when_current_controller_matches
    with_controller_class(Moduler::ProfileController) do
      fragment = render_inline(Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "moduler/profile"))

      assert_not_empty fragment.css("a.bg-slate-100.font-medium")
      assert_empty fragment.css("a.text-slate-500")
    end
  end

  def test_renders_inactive_link_when_current_controller_does_not_match
    with_controller_class(Moduler::SessionsController) do
      fragment = render_inline(Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "moduler/profile"))

      assert_not_empty fragment.css("a.text-slate-500")
      assert_empty fragment.css("a.bg-slate-100")
    end
  end

  def test_active_compares_full_controller_path
    with_controller_class(Moduler::ProfileController) do
      component = Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "profile")
      render_inline(component)

      assert_not component.active?
    end
  end

  def test_active_returns_true_when_current_controller_matches
    with_controller_class(Moduler::ProfileController) do
      component = Moduler::SidebarActionComponent.new("Profile", "/application/profile/edit", "moduler/profile")
      render_inline(component)

      assert component.active?
    end
  end
end
