# staffplan_redux

If at first you don't plan, plan again.

## StaffPlan v3 Now

Our useful staff planning service (https://github.com/goinvo/StaffPlan) was a bit long in the tooth. And we needed ~6 small math operations (total actual vs planned hours on a single project) + a better all-projects n' people view... and after a few years of fumbling with custom Airtables + google sheets and trying Runn, they all sucked and couldn't measure up to StaffPlan.

So time for an update.

## Ship date = late Jan-ish 24

## Installation

For local development we'll assume a couple of things:

1. You have a working Ruby 3.2.0 installation
2. You have bundler installed
3. You have Docker installed

Additionally, this app assumes you've got access to the 1Password account where the secrets are stored. Eventually these will live in a repository owned by GoInvo.

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
