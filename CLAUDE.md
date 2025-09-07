# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StaffPlan Redux is a Rails 8.0.2 application for staff planning and project management. It's a rewrite of the original StaffPlan service, focusing on collaborative work planning where team members can propose projects and track their time.

## Key Commands

### Development Server
```bash
bin/dev                 # Starts Rails server, Tailwind CSS watcher, SolidQueue jobs, and Stripe webhook listener
bin/rails server        # Start just the Rails server on port 3000
```

### Testing
```bash
bin/rails test                              # Run all Minitest tests
bin/rails test test/controllers/file.rb    # Run specific test file
bin/rails test test/controllers/file.rb:8  # Run test at specific line
bundle exec rubocop                         # Run Rubocop linter
bundle exec rubocop -a                      # Auto-fix Rubocop violations
```

### Database
```bash
bin/rails db:migrate        # Run pending migrations
bin/rails db:seed          # Seed database with test data
bin/rails db:setup         # Create, migrate, and seed database
bin/rails console          # Open Rails console
```

### Asset Management
```bash
bin/rails tailwindcss:build    # Build Tailwind CSS
bin/rails tailwindcss:watch    # Watch and rebuild Tailwind CSS
bin/rails assets:precompile    # Precompile all assets
```

## Architecture Overview

### Authentication & Authorization
- Uses **Passwordless** gem for authentication (no passwords, email-based login)
- SessionsController extends Passwordless::SessionsController
- Feature flags via **Prefab** for controlling access and UI variations
- Test users: owner@acme.co, admin@acme.co, member@acme.co

### Core Domain Models
- **User**: Can belong to multiple companies via Membership
- **Company**: Has many users, projects, and clients
- **Assignment**: Links users to projects with status (proposed/active/archived/completed)
- **WorkWeek**: Tracks estimated and actual hours per week for assignments
- **Project**: Belongs to client, has assignments and work weeks
- **Client**: Belongs to company, has projects

### View Components
Located in `app/components/`, using ViewComponent gem:
- `StaffPlan::AssignmentComponent`: Displays user assignments with 26-week timeline
- Components use unpersisted WorkWeek objects for empty weeks in the timeline

### GraphQL API
- Endpoint: POST /graphql
- Located in `app/graphql/`
- Uses DataLoader pattern for N+1 query prevention
- GraphiQL available at /graphiql in development

### Background Jobs
- Uses **SolidQueue** for job processing
- Stripe webhook processing handled asynchronously

### Billing Integration
- **Stripe** integration for subscriptions
- Webhooks endpoint: /webhooks/stripe
- Customer portal and billing managed through Stripe

### Testing Approach
- **Minitest** for testing (recently converted from RSpec)
- Factory Bot for test data generation
- VCR for recording external API interactions
- Test files use standard Minitest syntax, not RSpec-style

### Code Style
- Rubocop with custom configuration in .rubocop.yml
- Rails Omakase styling guidelines
- ViewComponent for encapsulated UI components
- Avoid adding comments unless specifically requested

## Important Patterns

### Null Object Pattern
WorkWeek objects are created but not persisted when displaying empty weeks in the timeline, allowing uniform handling of existing and non-existing data.

### Feature Flags
Prefab is used extensively for feature flags. Check with `Prefab.enabled?('feature-name', context)` before assuming features are available.

### Testing Gotchas
- Use `ActionController::TestCase` for controller tests that need the `tests` method
- Integration tests should use path helpers (e.g., `registrations_path`) not symbols
- Avoid RSpec-style syntax (describe/it) - use Minitest's `test` blocks

### Rails-specific Considerations
- Using Rails 8.0.2 with Ruby 3.4.4
- PostgreSQL database
- Tailwind CSS for styling
- ImportMaps for JavaScript (no Webpack/Node build step)
- Turbo and Stimulus for interactivity

## Environment Setup Notes
- Stripe setup required for full functionality (see README for details)
- Docker setup available for UI-only development
- Letter Opener Web at /letter_opener in development for viewing emails
- Uses .env files for local environment variables (via dotenv-rails)