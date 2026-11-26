# Fork release tools

This branch (`fork/tools`) holds only the tooling for building releases
of this fork. It shares no history with Ruffle.

## Layout

| Branch | Contents |
|---|---|
| `master` | An exact copy of upstream Ruffle's `master`. Never committed to. |
| `pr/*` | One fix each. Starts from upstream and never merges another fix. |
| `fork/tools` | `branches.txt`, `release.sh` and this README. |

Releases are tags named `fork-YYYY.MM.DD`, with a GitHub Release holding
the web (self-hosted) build.

## How a release is made

`release.sh` takes the fork's `master` and merges each branch in
`branches.txt` into it, one merge commit per fix. It then runs the test
suite, builds the web player, tags the result and publishes the release.

Each release is built from scratch, so no branch is ever rewritten and
the fix branches are never changed by a release. The lineage of any
release can be read with:

    git log --first-parent --oneline fork-YYYY.MM.DD

which shows the Ruffle commit it starts from, then one merge per fix.
The release notes, and `branches.txt` inside the zip, list that commit
and the commit of each fix branch.

## Keeping up with upstream Ruffle

Releases are built on the fork's `master`, not on the latest upstream.
So the fork only picks up new Ruffle changes when you choose to, and a
release never breaks just because upstream moved.

To update:

1. Move the fork's `master` forward to upstream (GitHub's "Sync fork"
   button, or a fast-forward push). It must stay an exact copy of
   upstream; `release.sh` refuses a `master` with commits of its own.
2. Run `release.sh --dry-run`. It stops at the first fix branch that
   conflicts with the new base, or reports failing tests.
3. Update just that branch: merge the fork's `master` into it, resolve
   the conflict there, test it, and push. Repeat from step 2.

Updating a branch by merging needs no force push, keeps its name, and
`git diff master...pr/x` still shows only the fix.

The alternatives, and why they weren't chosen:

- Rebase the branch onto the new base. Gives the tidiest history, but
  rewrites the branch and needs a force push every time.
- Merge upstream into every branch on a schedule. Keeps them all
  current, but fills them with merge commits that change nothing.

## Safety

`release.sh` refuses to run unless `origin` is this fork and the
`upstream` remote has its push URL disabled, so it cannot write to the
official Ruffle repository.
