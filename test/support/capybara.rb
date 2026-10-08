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

# let tests find icon-only buttons by their accessible name
Capybara.enable_aria_label = true
