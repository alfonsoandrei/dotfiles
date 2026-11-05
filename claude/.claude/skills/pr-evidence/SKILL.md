---
name: pr-evidence
description: Prepare manual test evidence for a pull request with the hurl test harness - plan the test cases from the code and the contract, write the ticket's test cases, run them in tmux panes, render PNGs and draft the PR "Testing notes", and a QA test plan for Jira. Use when a PR is finished or ready for review, or when Andrei asks for manual tests, a test plan, test evidence, screenshots for a PR, or to rerun a ticket's tests.
---

# PR evidence with the hurl harness

Every PR ends with manual tests and evidence: for each test case, the request, the response, and the
database before and after. Andrei pastes the PNGs and the notes into the PR. Nothing is posted by you.

The harness lives in `~/Documents/git/dev-tooling` (README.md, tickets/README.md, AGENTS.md). Its tools are on
`PATH`: `mq`, `req`, `check`, `snapshot`, `pane2png`, `ticket-evidence`. Each takes `-t <KEY>`. Andrei
browses everything with `hx` (fzf, `ctrl-o` switches requests, queries, evidence), so give every case a
first `#` line, every query an `"about"`, and every ticket a `ticket.json` feature: that is what he searches.

## 1. Preflight

1. api-core runs locally on the PR's branch (`CORE_URL` in `envs/local.env`, port 8090). If not, see
   README "Local api-core". If `yarn` fails on the CodeArtifact token, run `dev-login` yourself.
2. Docker services are up (`docker compose up -d` in api-core). The app uses the native `mongod`.
3. No snapshot waits for a restore: `snapshot status -t <KEY>`.

## 2. Plan the test cases

Plan the cases before you write a `.hurl` file. Keep the plan in `tickets/<KEY>/test-plan.md`. The same
plan becomes the QA plan for Jira (step 5).

1. **Read the sources, not a run.** Read the PR description, the ticket, the design or contract, and the
   code of each route: controller, guards, DTOs, services, repositories and error messages. An expected
   result comes from the contract and the code, never from what a run returned.
2. **List what the PR promises:** each route and its auth, the validation, each rule and state change,
   each unique rule, each response field and each message.
3. **Find the cases with these techniques.** Each one finds cases that the happy path misses.
   - **Access:** no key, the wrong kind of key (a partner key on an admin route), a feature flag off and
     on, an unknown partner, and another partner's data.
   - **Decision table:** one case for each branch of a rule function, and one for each precedence when
     two inputs disagree.
   - **Boundaries:** for each limit, the last valid value and the first invalid one (10 and 11 digits, 0
     and 1, null and empty).
   - **State transitions:** forward, back, the same state, and a change that must not happen.
   - **Idempotency:** the same request again, and the same key with changed values.
   - **Unique rules:** each rule inside its scope and across it (per borrower, per user, per partner,
     across files). Also what does not hold a key, such as a Not payable row.
   - **All or nothing:** a valid item, then an invalid one, in the same request.
   - **Reads:** the fields present and absent, the sort order, an empty list and a 404.
   - **Exposure:** the route stays out of the API docs, and no internal field leaks.
   - **Lifecycle:** a flag turned off after data exists.
4. **Plan the data.** The cases run in order on shared data. Give each row its own IDs, unless a case
   reuses them on purpose. Write down what each case leaves for the next one.
5. **Write each case:** preconditions, numbered steps, and expected results. An expected result names
   the status, the message or fields, the stored state, and what must not change.
6. **Ask Codex to check the plan against the code** before you run anything:
   `codex exec --skip-git-repo-check --sandbox read-only "<prompt>" < /dev/null`, from the repo of the PR.
   Ask it to verify each expected result, the state that each case leaves for the next, and the
   behaviour that no case covers. Fix the plan, then run a final Codex pass on the fixes.

Each case of the plan becomes one `.hurl` file, one `check` and one window in step 3.

## 3. Write the ticket

Start from `tickets/_template` (`cp -R tickets/_template tickets/<KEY>`).

- `ticket.json`: a short title and the **feature**. Reuse an existing feature name if it fits:
  `grep -h '"feature"' tickets/*/ticket.json | sort -u`.
- `NN-<case>.hurl`: one case per behavior. **Every expected result needs an assert**: the status, and
  the exact message or field with `jsonpath`. The first `#` line describes the case.
- `mongo/NN-<case>.js`: a read-only check for what the case writes. Use `snapshot.get(...)` for "before".
  Its first `//` line says what it checks; the next lines say when it runs and what good looks like.
- `queries.json`: named reads that the panes show, each with an `"about"` (one line) and `"details"`
  (what it shows, for which records, what to look for before and after). Reuse a shared query from
  `queries/` (`mq` lists them) before you write a new one. No credentials collection, no personal fields.
- `vars/local.vars`: `MONGO_DB` and the test ids. **Check that a test partner's id is not a credential**:
  hurl shows it as `***` in the sent URL if it is. Never use DwollaPartner.
- `evidence.json`:
  - `backup`: every document a writing case changes. `clearCache` for cached ones (`PARTNERS`).
  - `cases`: a `filter` for a long response body; `writes` to correct the method rule.
  - `windows`: one per test case of the PR, with `title`, `steps`, `expected`, a layout
    (`single`, `columns`, `request-left`) and panes (`req`, `mq`, `check`, `run`) in run order. Show the data
    before and after a write, and add a `check` pane so the database result is asserted.
  - `commands`: for a `run` pane, a named shell line for what hurl cannot send, such as a secure-proxy Lambda
    (`lambda-local ... | log-brief`, with `secure-proxy-local` running). Secrets as `pass:` references only.
    hurl README "Local secure-proxy and its Lambdas"; `tickets/DRP-8446` is the example.

## 4. Run

```
ticket-evidence <KEY> --png
```

It saves a snapshot, runs the panes in order, restores and verifies the snapshot, renders the PNGs and
writes `testing-notes.md`. Read the result. A failed step stops the later ones; fix the case or report
the defect, then run again. Fix every `pane2png` width warning. A ✅ means every step of the window
passed, so it is only true when the asserts and checks cover each expected line.

Writes run on local only. Never send a write to DEV or QA (`--allow-write`) without Andrei's yes. There
is no prod.

## 5. Hand over

Tell Andrei:

- the panes: `tmux switch-client -t evidence-<KEY>`;
- the PNG folder and `testing-notes.md` (`tickets/<KEY>/evidence/local/<time>/`);
- the "Testing notes" text, ready to paste: each test case with its steps, an image slot per PNG, and
  the expected results. Offer to put it on the clipboard (`pbcopy`).

If Andrei wants a QA plan for Jira, write it from `test-plan.md` with no local tools in it. It has the
scope and references, the environment and test data, the entry and exit criteria, the cases, a short
exploratory charter, and a production smoke check with no writes. QA checks each result through the
API where it can. Run a Codex check on it, as in step 2.

Commit the ticket folder in the hurl repo only when Andrei asks, with his personal identity (the repo's
local git config). Evidence folders are git-ignored.
