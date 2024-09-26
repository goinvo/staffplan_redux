# staffplan_redux

If at first you don't plan, plan again.

## StaffPlan v3 Now

Our useful staff planning service (https://github.com/goinvo/StaffPlan) was a bit long in the tooth. And we needed ~6 small math operations (total actual vs planned hours on a single project) + a better all-projects n' people view... and after a few years of fumbling with custom Airtables + google sheets and trying Runn, they all sucked and couldn't measure up to StaffPlan.

So time for an update.

## StaffPlan is...
![A Project Staffplan](https://github.com/goinvo/staffplan_redux/blob/main/public/StaffPlan_Individual_Project.png)
![An individual's StaffPlan](https://github.com/goinvo/staffplan_redux/blob/main/public/StaffPlan_Individual.png)

## It's also...
Design Your Work Future with StaffPlan<br>
Imagine a tool that allows you and your team to shape your own work path. StaffPlan is designed to give you more control over what projects you’re involved in and how you map out your future work. Instead of rigid top-down planning, StaffPlan lets you suggest, discuss, and plan alongside your team leads and department heads.<br>

Have a project idea you’re passionate about? Like working on California health policy design or affordable housing initiatives? Stub in that project, share it with your group lead, and start a conversation about how to make it happen. It’s about taking initiative, not waiting for assignments.<br>

StaffPlan puts the power in the hands of your project teams to self-plan and track their workload, whether you’re entering routine tasks or bigger, long-term projects. Want to see what your workload looks like down the road? StaffPlan helps ensure you and your team are covered for weeks, months, and even a year into the future.<br>

But we know planning isn’t always enough – it’s also about making sure everything gets done. That’s why we’ve built in a simple, brain-dead easy timecard system. You get a quick text or email at the end of the week with your hours pre-filled. All you need to do is confirm with a click. It’s that simple.<br>

Planning doesn’t have to be complicated or rigid. With StaffPlan, you’re part of the conversation about where you’re going and what you’re working on. It’s a cultural shift toward more open, collaborative planning – and we’re here to support that.

## Want to run an instance for yourself? Here's the foundational setup

Running the **full** backend for StaffPlan requires an active Stripe account. If you'll just be doing UI development, **you may not need to set this up**.

You'll need to create a free account on Stripe. You'll be editing your credentials file with the `rails credentials:edit` command. This should create 
a new master encryption key and encrypted credentials file for you. Populate it with the contents of development.yml.enc from this repo. Note that 
if you're using the fully dockerized version of the backend, you'll need to prefix these commands like

```
docker compose -f docker-compose-dev.yml run web bin/rails credentials:edit
```

First, generate a new secret_key_base via `rails secret`, save its value in your credentials file as the `secret_key_base` key's value.

Next, go to the [developer API keys](https://dashboard.stripe.com/test/apikeys) page and add the secret key (starts with `sk_test_...`) to your credentials
as the `stripe_api_key` key's value.

Next, run `rake script:bootstrap` (or `docker compose -f docker-compose-dev.yml run web bin/script:bootstrap`) locally. This will create the 
necessary product/price and customer billing portal configuration in your Stripe account. Note that the output will provide you two values 
you'll need to save in your credentials file. If you get stuck, you'll need to grab the `price_id` and the billing portal's `login_page.url` from y
our Stripe account's UI, and save them as the `stripe_price_id` and `stripe_login_url` keys' values respectively.

Finally, you'll need to ensure that you're able to receive webhooks from Stripe. The recommended way to do this is to
use [Stripe's local CLI](https://dashboard.stripe.com/test/webhooks/create?endpoint_location=local). You can also configure a webhook to point
to your local system via a reverse proxy like ngrok or VSCode devtunnels. However you choose to do this, you'll need to save the value of the webhook's
signing secret in your credentials file as the `stripe_signing_secret` key's value.

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
