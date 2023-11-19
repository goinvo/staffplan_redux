# staffplan_redux

If at first you don't plan, plan again.

## Installation

For local development we'll assume a couple of things:

1. You have a working Ruby 3.2.0 installation
2. You have bundler installed
3. You have Docker installed

If you don't have any of these things, please install them before continuing. When you've got the minimum requirements, running the following should get you up and running:

```bash
bundle install
gem install kamal
kamal envify --skip-push
docker compose up --detach
bin/rails db:setup
bin/dev
```

Ensure that the test suite runs and is green:

```bash
rspec
```