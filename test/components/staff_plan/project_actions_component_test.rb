# frozen_string_literal: true

require 'test_helper'

module StaffPlan
  class ProjectActionsComponentTest < ActionView::TestCase
    describe 'StaffPlan::ProjectActionsComponent' do
      setup do
        @assignment = create(:assignment)
        @component = StaffPlan::ProjectActionsComponent.new(assignment: @assignment)
      end

      test 'renders the component' do
        render_inline(@component)

        assert_selector 'div[data-menu-target="menu"]'
      end

      test 'component is hidden by default' do
        render_inline(@component)

        assert_selector 'div.hidden[data-menu-target="menu"]'
      end

      test 'has proper dropdown styling' do
        render_inline(@component)

        assert_selector 'div[data-menu-target="menu"].absolute.right-0.bg-white.rounded-md.shadow-\[0_4px_4px_0_rgba\(0\,0\,0\,0\.25\)\]'
      end

      test 'renders edit project button' do
        render_inline(@component)

        assert_selector 'button[role="menuitem"]', text: 'Edit project'
      end

      test 'renders hide in my staffplan button' do
        render_inline(@component)

        assert_selector 'button[role="menuitem"]', text: 'Hide in My StaffPlan'
      end

      test 'renders export csv button' do
        render_inline(@component)

        assert_selector 'button[role="menuitem"]', text: 'Export CSV'
      end

      test 'renders archive project button with red text' do
        render_inline(@component)

        assert_selector 'button[role="menuitem"].text-\[\\#FF5E5E\]', text: 'Archive project for everyone'
      end

      test 'archive button has top border' do
        render_inline(@component)

        assert_selector 'button.border-t', text: 'Archive project for everyone'
      end

      test 'all buttons have hover state' do
        render_inline(@component)

        assert_selector 'button.hover\:bg-gray-100', count: 4
      end

      test 'menu has proper ARIA attributes' do
        render_inline(@component)

        assert_selector 'div[role="menu"][aria-orientation="vertical"]'
      end

      test 'all menu items have proper role' do
        render_inline(@component)

        assert_selector 'button[role="menuitem"]', count: 4
      end
    end
  end
end
