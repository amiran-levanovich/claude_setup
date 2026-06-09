## Project Overview
This workspace handles Ruby and Ruby on Rails applications. All development, refactoring, database design, and testing protocols must align with the local ecosystem standards.

## The Agent Knowledge Base (agent_docs/)
A dedicated reference library is maintained at `agent_docs/` in the project root. This path is always relative — the same setup works across any project.

**Core Rule**: Memory is volatile; documentation is deterministic. When tasked with execution in any of the above domains, read the corresponding markdown file in agent_docs/ first.

## Standard Commands
### 1. Environment Setup
* Install dependencies: `bundle install`
* Create and migrate database: `rails db:create db:migrate`
* Seed database: `rails db:seed`
* Reset database: `rails db:drop db:create db:migrate db:seed`

### 2. Development Server
* Start all processes (Rails 7+): `bin/dev`
* Rails server only: `bundle exec rails server`

### 3. Verification & Testing
* Run Entire Suite: `bundle exec rspec`
* Run Single Spec: `bundle exec rspec spec/path/to/file_spec.rb`
* Run Linter (RuboCop): `bundle exec rubocop`
* Auto-Correct Style: `bundle exec rubocop -A`

### 4. Rails Generators — Usage Policy
* **Use:** `rails generate model`, `rails generate migration`, `rails generate controller` — single-concern, explicit.
* **Avoid:** `rails generate scaffold` — generates views, helpers, and assets that pollute the codebase when TDD is active.
* **Never** generate specs via generators; write them manually per `agent_docs/coding_workflow.md`.