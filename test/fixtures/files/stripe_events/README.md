# Stripe webhook event fixtures

`test/requests/webhooks/stripe_test.rb` signs these events with a test secret and posts them to `/webhooks/stripe`.
Each file is one complete Stripe `Event`. Its `api_version` must match the API version of the production webhook
endpoint (Dashboard → Developers → Webhooks → the endpoint → API version), because Stripe renders webhook payloads in
the endpoint's version, not the version the `stripe` gem pins. As of October 2026 the production endpoint is on
`2023-10-16`; the tests also cover the `2025-03-31.basil`-and-later shape, where `quantity` and the billing period live
only on subscription items.

| File | Scenario |
| --- | --- |
| `customer.subscription.created.json` | `Stripe::CreateCustomerJob` creates a 30-day trial for 3 seats |
| `customer.subscription.updated.json` | Trial converts to active with a card on file; seats go 3 → 4 |
| `customer.subscription.updated.cancel_at_period_end.json` | Owner cancels from the billing portal; active until period end |
| `customer.subscription.updated.renewal.json` | Monthly renewal; modeled on a real production event with ids replaced |
| `customer.subscription.deleted.json` | Subscription ends |
| `customer.updated.json` | Customer gets a default card payment method; fields match a real production event |

## Re-capturing from Stripe test mode

Do this when the endpoint's API version changes or when upgrading the `stripe` gem.

1. Run the app locally against a Stripe test-mode account (see the setup section of the main README).
2. Forward events and print them as JSON. `--load-from-webhooks-api` uses a webhook endpoint configured in the
   Dashboard, including its API version, so the captured payloads match production:

   ```bash
   stripe listen --load-from-webhooks-api --forward-to localhost:3000 --print-json \
     --events customer.subscription.created,customer.subscription.updated,customer.subscription.deleted,customer.updated \
     > /tmp/stripe-events.jsonl
   ```

3. Walk through the scenarios in the app: sign up a new company, invite a user, add a card through Checkout, cancel
   in the billing portal, then cancel the subscription immediately from the Dashboard.
4. Save each event into the matching file, pretty-printed. Swap real ids and emails for the placeholders the tests use:
   `cus_TestStaffPlan01`, `sub_TestStaffPlan01`, `si_TestItem0001`, `price_TestMonthly01`, `pm_TestCard00001`.
5. Update the timestamps the tests assert against, then run `bin/rails test test/requests/webhooks/stripe_test.rb`.

## Re-recording VCR cassettes

Tests that call the Stripe API replay HTTP from `test/cassettes`. The `Stripe-Version` request header in a cassette
shows which API version it was recorded with. To re-record against the gem's current version:

1. Set `stripe_api_key` (a test-mode `sk_test_...` key) and `stripe_price_id` in the test credentials.
2. Delete the cassettes to refresh, e.g. `rm -r test/cassettes/Subscription_Management`.
3. Run the tests that use them. VCR records new cassettes on the first run, and the bearer token is filtered out.
4. Check the new cassettes for real customer names or emails before committing them.
