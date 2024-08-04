# staffplan_redux

If at first you don't plan, plan again.

## StaffPlan v3 Now

Our useful staff planning service (https://github.com/goinvo/StaffPlan) was a bit long in the tooth. And we needed ~6 small math operations (total actual vs planned hours on a single project) + a better all-projects n' people view... and after a few years of fumbling with custom Airtables + google sheets and trying Runn, they all sucked and couldn't measure up to StaffPlan.

So time for an update.

## Ship date = late Jan-ish 24

## Docker installation

These instructions will create a local environment for running StaffPlan locally for the purposes of developing the UI. This
is not a great environment for developing the backend (Rails) app as it doesn't have a debugger or other development tools
set up. It's meant to provide a way for UI developers to work on the front end without needing to install Ruby or Rails on their
local systems.

```bash
docker compose -f docker-compose-dev.yml build
docker compose -f docker-compose-dev.yml up -d
docker compose -f docker-compose-dev.yml run web bin/rails db:create # ignore any errors here
docker compose -f docker-compose-dev.yml run web bin/rails db:migrate db:seed
docker compose -f docker-compose-dev.yml run web bin/rails assets:precompile
```

To sign in, you'll need to sign in with `owner@acme.co`, `admin@acme.co`, or `member@acme.co`. These accounts are all on the Acme Co. account
with the respective role attached. In order to sign in, you'll enter this email into the sign in form. Since Docker can't open the browser on
your local machine, you'll need to check http://localhost:3000/letter_opener/ for the recent emails sent by the system.

## non-Docker Installation

For local development we'll assume a couple of things:

1. You have a working Ruby 3.2.0 installation
2. You have bundler installed
3. You have Docker installed

Additionally, this app assumes you've got access to the 1Password account where the secrets are stored. Eventually these will live in a repository owned by GoInvo.

If you don't have any of these things, please install them before continuing. When you've got the minimum requirements, running the following should get you up and running:

```bash
bundle install

##########################################################################
# only need this for deploying the app, otherwise this should be skipped
gem install kamal 
kamal envify --skip-push
##########################################################################

docker compose up --detach
bin/rails db:setup
bin/dev
```

Ensure that the test suite runs and is green:

```bash
rspec
```
