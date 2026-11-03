---
name: pr-evidence
description: Prepare manual test evidence for a pull request with the hurl test harness - write the ticket's test cases, run them in tmux panes, render PNGs and draft the PR "Testing notes". Use when a PR is finished or ready for review, or when Andrei asks for manual tests, test evidence, screenshots for a PR, or to rerun a ticket's tests.
---

# PR evidence with the hurl harness

Every PR ends with manual tests and evidence: for each test case, the request, the response, and the
database before and after. Andrei pastes the PNGs and the notes into the PR. Nothing is posted by you.

The harness lives in `~/Documents/git/hurl` (README.md, tickets/README.md, AGENTS.md). Its tools are on
`PATH`: `mq`, `req`, `check`, `snapshot`, `pane2png`, `ticket-evidence`. Each takes `-t <KEY>`. Andrei
browses everything with `hx` (fzf, `ctrl-o` switches requests, queries, evidence), so give every case a
first `#` line, every query an `"about"`, and every ticket a `ticket.json` feature: that is what he searches.

## 1. Preflight

1. api-core runs locally on the PR's branch (`CORE_URL` in `envs/local.env`, port 8090). If not, see
   README "Local api-core". If `yarn` fails on the CodeArtifact token, run `dev-login` yourself.
2. Docker services are up (`docker compose up -d` in api-core). The app uses the native `mongod`.
3. No snapshot waits for a restore: `snapshot status -t <KEY>`.

## 2. Write the ticket

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
    (`single`, `columns`, `request-left`) and panes (`req`, `mq`, `check`) in run order. Show the data
    before and after a write, and add a `check` pane so the database result is asserted.

## 3. Run

```
ticket-evidence <KEY> --png
```

It saves a snapshot, runs the panes in order, restores and verifies the snapshot, renders the PNGs and
writes `testing-notes.md`. Read the result. A failed step stops the later ones; fix the case or report
the defect, then run again. Fix every `pane2png` width warning. A ✅ means every step of the window
passed, so it is only true when the asserts and checks cover each expected line.

Writes run on local only. Never send a write to DEV or QA (`--allow-write`) without Andrei's yes. There
is no prod.

## 4. Hand over

Tell Andrei:

- the panes: `tmux switch-client -t evidence-<KEY>`;
- the PNG folder and `testing-notes.md` (`tickets/<KEY>/evidence/local/<time>/`);
- the "Testing notes" text, ready to paste: each test case with its steps, an image slot per PNG, and
  the expected results. Offer to put it on the clipboard (`pbcopy`).

Commit the ticket folder in the hurl repo only when Andrei asks, with his personal identity (the repo's
local git config). Evidence folders are git-ignored.
