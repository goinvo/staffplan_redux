# frozen_string_literal: true

# Run using bin/ci

CI.run do
  step 'Setup', 'bin/setup --skip-server'

  step 'Style: Ruby', 'bin/rubocop'

  step 'Security: Importmap vulnerability audit', 'bin/importmap audit'

  step 'Assets: Build Tailwind CSS', 'bin/rails tailwindcss:build'
  step 'Tests: Rails', 'bin/rails test'
  step 'Tests: System', 'bin/rails test:system'
end
