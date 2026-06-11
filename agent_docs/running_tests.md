# Testing Strategy & Execution Runbook

This runbook defines the testing hierarchy, testing priorities, and execution constraints for this workspace. You must adapt your test-generation behavior strictly based on whether the application is a full-stack monolith or an API-only application.

## TESTING PRIORITIES

In this workspace, isolated unit tests are a low priority. The highest priority is placed on System/Integration tests that verify real-world user behavior and end-to-end functional contracts.

 **HIGHEST PRIORITY**: End-to-End / System Specs (User Flows) | Request Specs (API Contract & Error Handling)

 **LOWEST PRIORITY**:  Unit Tests / Isolated Model Methods


## MONOLITH / FULL-STACK APPS: SYSTEM SPECS

For applications with a user interface, focus your efforts on RSpec System Specs (Capybara). We care about the critical user journey (e.g., clicking an "Add to cart" button updates the correct product, in the correct cart, for the correct user).

## Performance Guardrails (Keep it under 10 minutes)

System tests can become notoriously slow. To ensure the suite remains incredibly fast, adhere to these strict execution rules:

### Headless Driving Only
**Always** use a headless browser driver (e.g., Headless Chrome via driven_by :selenium, using: :headless_chrome or driven_by :cuprite). Never boot a full visual browser window.

### No Animation Waits
Disable CSS transitions and animations in the test environment (config.public_file_server.headers or middleware) so Capybara doesn't waste seconds waiting for UI fades.

### Transactional Rollbacks
Ensure DatabaseCleaner or ActiveRecord's native transactional testing is active so the database resets instantly between system clicks without running heavy truncation scripts.

### Surgical Scope
Do not write a system spec for every single permutation of an input field. Write one happy path system spec for the user flow, and push edge-case validation checks down into request or service layer specs.

## API-ONLY APPS: REQUEST SPECS & MOCKING

For headless or API-only Rails applications, your primary tool is the Request Spec. You must test the strict input/output contract of the controller endpoints.

### The Total Mocking Mandate

Never Make Real Network Requests: You are strictly forbidden from hitting live third-party production or staging servers during a test execution.

Stubs & Mocks: Use tools like WebMock or VCR to intercept out-of-network HTTP calls. If a service calls an external API, mock the response explicitly at the network layer.

### Coverage Matrix

For every API endpoint you test, you must explicitly construct assertions for three distinct layers:

* Happy Path (Valid parameters, 200/201 Created status, exact payload matches)
* Bad Path (Invalid parameters, 422 Unprocessable Entity, malformed payloads)
* Edge Cases & Fault Tolerance (Third-party API downtime, 500 errors, timeouts)


Error Handling Verification: **Do not** just test that the application crashes gracefully. Assert that the JSON response returns the correct error schema, descriptive error keys, and the accurate HTTP status code.

## FACTORYBOT STRATEGY

Define one factory per model in `spec/factories/`. Use traits for variations — never duplicate factories.

```ruby
FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    name  { Faker::Name.name }

    trait :admin do
      role { 'admin' }
    end
  end
end
```

Rules:
- Use `build` (no DB hit) in model and service specs.
- Use `create` only in system and request specs that require persisted records.
- Never mix factories and fixtures in the same suite.

## PARALLEL TEST EXECUTION

When the suite exceeds 10 minutes, enable parallelization via the `parallel_tests` gem.

```ruby
# Gemfile (test group)
gem 'parallel_tests'
```

Setup and run:
```bash
bundle exec rake parallel:setup          # creates one DB per CPU worker
bundle exec parallel_rspec spec/         # runs the full suite in parallel
```

Note: system specs are safe to parallelize only when each worker uses an isolated database — `parallel:setup` handles this automatically.

## EXECUTION CHEAT SHEET

Always use these direct commands when running tests via your built-in Bash tool:

## Running System/E2E Specs

### Run all system/feature specs
``bundle exec rspec spec/system``

### Run a single system file
``bundle exec rspec spec/system/<feature>_spec.rb``

### Run a specific example by line number
``bundle exec rspec spec/system/<feature>_spec.rb:<line>``


## Running API/Request Specs

### Run all request specs
``bundle exec rspec spec/requests``

### Run a single controller/endpoint contract
``bundle exec rspec spec/requests/api/v1/<resource>_spec.rb``


## Fast-Fail Optimization

When debugging a broken workflow, always append the ``--fail-fast`` flag so the test runner halts on the very first error instead of dragging out execution times across the entire suite:

``bundle exec rspec spec/system/<feature>_spec.rb --fail-fast``

## SELF-VALIDATION CHECKLIST

STOP after writing or changing specs. Check every item before presenting them. If an item fails, fix it first.

1. **Right level:** Is each behavior tested at the highest-priority level that fits — system spec for user flows (monolith), request spec for API contracts — rather than a low-priority unit test?
2. **Coverage matrix (APIs):** Does every endpoint assert all three layers — happy path, bad path (422 + payload), and fault tolerance (third-party downtime/timeouts)?
3. **Error schema:** Do error-path assertions check the exact status code and error payload shape — not merely "doesn't crash"?
4. **No real network:** Is every third-party call stubbed at the network layer (WebMock/VCR)?
5. **Factory discipline:** `build` in model/service specs, `create` only where persistence is required, traits instead of duplicated factories?
6. **Surgical scope:** One happy-path system spec per user flow, with edge cases pushed down to request/service specs?

### Anti-pattern scan
- [ ] Spec that hits a live external service
- [ ] Multiple unrelated assertions in one example (unclear which broke)
- [ ] Near-identical examples copy-pasted with small changes — extract shared setup or use shared examples
- [ ] `create` where `build` would do
- [ ] System spec testing an input-validation permutation that belongs in a request spec

### Judgment calls
When test granularity or mocking depth is genuinely ambiguous (mock a collaborator vs let the call go through; one example with several related assertions vs several examples), present the options instead of silently choosing.
