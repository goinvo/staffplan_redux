# frozen_string_literal: true

# Chrome reports a node that was swapped out mid-check (e.g. by a Turbo page
# update) as a generic UnknownError ("Node with given id does not belong to the
# document") instead of StaleElementReferenceError, so Capybara doesn't retry
# it. Treat it as retryable; a genuine UnknownError still raises once
# Capybara's wait time runs out.
module RetryUnknownSeleniumErrors
  def invalid_element_errors
    super + [Selenium::WebDriver::Error::UnknownError]
  end
end

Capybara::Selenium::Driver.prepend(RetryUnknownSeleniumErrors)

# Chrome 158 rejects the "*" origin Capybara 3.40 passes to
# Storage.clearDataForOrigin in reset!, erroring every system test's teardown
# (teamcapybara/capybara#2865). Clear all cookies and the test server's local
# storage instead. Drop this once a Capybara release fixes it.
module ClearChromeStorageWithoutWildcard
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    server = Capybara.current_session.server
    return unless server && params[:storageTypes].include?('local_storage')

    super(cmd, { origin: server.base_url, storageTypes: 'local_storage' })
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ClearChromeStorageWithoutWildcard)

# let tests find icon-only buttons by their accessible name
Capybara.enable_aria_label = true
