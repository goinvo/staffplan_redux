# frozen_string_literal: true

require 'test_helper'

module Timeline
  class PageHeaderComponentTest < ViewComponent::TestCase
    test 'shows the title, avatar and extra details' do
      render_inline(PageHeaderComponent.new(title: 'Jane Doe', avatar_url: 'https://example.test/jane.png')) { 'Acme, Jan 1' }

      assert_selector 'h1', text: /\A\s*Jane Doe\s*\z/
      assert_selector 'img[alt=Avatar][src="https://example.test/jane.png"]'
      assert_text 'Acme, Jan 1'
      assert_no_text '(Deactivated)'
    end

    test 'flags deactivated people and skips a missing avatar' do
      render_inline(PageHeaderComponent.new(title: 'Jane Doe', inactive: true))

      assert_selector 'h1', text: '(Deactivated)'
      assert_no_selector 'img'
    end
  end
end
