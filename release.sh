#!/usr/bin/env bash
# Builds a fork release: the fork's master (a copy of upstream Ruffle)
# plus every branch in branches.txt, tested, built for the web, tagged and published as a
# GitHub Release on the fork. It only ever writes to the fork.
#
# Usage: release.sh <ruffle clone> [--dry-run]
#   The clone needs remotes "origin" (the fork) and "upstream" (Ruffle).
#   --dry-run: merge, test and build, but don't tag or publish.
# Env: CARGO_TARGET_DIR (optional), RELEASE_NAME (default fork-YYYY.MM.DD)
set -euo pipefail

FORK=thenickman100/ruffle
TOOLS=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "${1:?usage: release.sh <ruffle clone> [--dry-run]}" && pwd)
DRY=${2:-}
NAME=${RELEASE_NAME:-fork-$(date -u +%Y.%m.%d)}
WORK=$(mktemp -d)/$NAME
OUT=$TOOLS/out/$NAME

die() { echo "ERROR: $*" >&2; exit 1; }
# git as the fork owner, in the given directory.
g() {
  local dir=$1; shift
  git -C "$dir" -c user.name=thenickman100 \
    -c user.email=156046666+thenickman100@users.noreply.github.com \
    -c commit.gpgsign=false -c tag.gpgsign=false "$@"
}

# Safety: origin must be the fork, and upstream must not be pushable.
[[ $(git -C "$REPO" remote get-url origin) == *"github.com/$FORK"* ]] \
  || die "origin is not $FORK"
[[ $(git -C "$REPO" remote get-url --push upstream) == http* ]] \
  && die "upstream is pushable; run: git remote set-url --push upstream DISABLED"

mapfile -t BRANCHES < <(sed 's/#.*//; s/[[:space:]]//g; /^$/d' "$TOOLS/branches.txt")
echo "== Fetching upstream and ${#BRANCHES[@]} branches"
g "$REPO" fetch -q upstream master
g "$REPO" fetch -q origin
BASE=$(g "$REPO" rev-parse origin/master)
g "$REPO" merge-base --is-ancestor "$BASE" upstream/master \
  || die "the fork's master has commits that aren't in upstream Ruffle"
LAG=$(g "$REPO" rev-list --count "$BASE..upstream/master")

echo "== Merging onto the fork's master ${BASE:0:10} ($LAG commits behind upstream)"
g "$REPO" worktree add -q --detach "$WORK" "$BASE"
trap 'git -C "$REPO" worktree remove --force "$WORK" 2>/dev/null || true' EXIT
mkdir -p "$OUT"
{
  echo "Release: $NAME"
  echo "Base: ruffle-rs/ruffle $BASE ($LAG commits behind its master)"
  echo
  echo "Branches (commit, commits behind the base):"
} > "$OUT/branches.txt"
for b in "${BRANCHES[@]}"; do
  sha=$(g "$WORK" rev-parse "origin/$b")
  behind=$(g "$WORK" rev-list --count "origin/$b..$BASE")
  printf '  %-34s %s  %s behind base\n' "$b" "${sha:0:10}" "$behind" | tee -a "$OUT/branches.txt"
  g "$WORK" merge -q --no-ff --no-edit -m "Merge $b (${sha:0:10}) into $NAME" "origin/$b" \
    || { g "$WORK" merge --abort; die "$b conflicts with the base; update that branch"; }
done
MERGED=$(g "$WORK" rev-parse HEAD)

echo "== Testing"
cd "$WORK"
# The web build looks for build output in ./target.
[[ -n ${CARGO_TARGET_DIR:-} ]] && ln -sfn "$CARGO_TARGET_DIR" target
cargo test --release -p tests --test tests 2>/dev/null > "$OUT/test.log" || true
grep -E '^test result' "$OUT/test.log" || die "tests did not run, see $OUT/test.log"
for t in $(sed -n 's/^    \([^ ]*\)$/\1/p' "$OUT/test.log" | sort -u); do
  # Retry each failure alone to tell flaky timing tests from real ones.
  ok=
  for _ in 1 2 3; do
    if cargo test --release -p tests --test tests -- --exact "$t" 2>/dev/null \
      | grep -q '^test result: ok. 1 passed'; then ok=1; break; fi
  done
  [[ $ok ]] || die "test fails: $t"
  echo "  flaky, passed alone: $t"
done

echo "== Building web"
(cd web && npm ci && npm run build --workspace=ruffle-core \
  && npm run build --workspace=ruffle-selfhosted) > "$OUT/build.log" 2>&1 \
  || die "web build failed, see $OUT/build.log"
rm -rf "${OUT:?}/$NAME" && mkdir -p "$OUT/$NAME"
cp -r web/packages/selfhosted/dist/. "$OUT/$NAME/"
cp "$OUT/branches.txt" "$OUT/$NAME/"
ZIP=$OUT/ruffle-$NAME-web.zip
(cd "$OUT" && rm -f "$ZIP" && zip -qr "$ZIP" "$NAME")
cd "$REPO"
echo "Built $ZIP"

[[ $DRY == --dry-run ]] && { echo "Dry run: not tagging or publishing"; exit 0; }

echo "== Publishing $NAME to $FORK"
g "$REPO" tag -a "$NAME" -F "$OUT/branches.txt" "$MERGED"
g "$REPO" -c push.negotiate=true push -q origin "refs/tags/$NAME"
id=$(gh api "repos/$FORK/releases" -f tag_name="$NAME" -f name="Ruffle $NAME" \
  -f body="$(printf 'Ruffle plus the fixes below. Web (self-hosted) build.\n\n```\n%s\n```' "$(cat "$OUT/branches.txt")")" \
  --jq .id)
gh api -X POST "https://uploads.github.com/repos/$FORK/releases/$id/assets?name=$(basename "$ZIP")" \
  -H "Content-Type: application/zip" --input "$ZIP" --jq .browser_download_url
echo "Published https://github.com/$FORK/releases/tag/$NAME"
