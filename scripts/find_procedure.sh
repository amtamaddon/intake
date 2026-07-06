#!/usr/bin/env bash
# Deterministic frontmatter lookup over procedures/**/*.md. No index, no staleness --
# the corpus is small enough that a scan is always cheap and always current.
# Filters to status: active unless --include-draft is passed, so an unapproved
# procedure structurally never reaches a builder through this sanctioned path.
#
# Usage: find_procedure.sh [--code CODE] [--payer PAYER] [--category CAT] [--include-draft] [term...]
# Prints: id | version | payer | title | path   (one per match)
# Exit 0 with hits, exit 3 on zero hits (distinct from a real error).
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
proc_dir="$repo_root/procedures"

code=""
payer=""
category=""
include_draft=0
terms=()

while [ $# -gt 0 ]; do
  case "$1" in
    --code) shift; code="${1:-}" ;;
    --payer) shift; payer="${1:-}" ;;
    --category) shift; category="${1:-}" ;;
    --include-draft) include_draft=1 ;;
    *) terms+=("$1") ;;
  esac
  shift
done

field() { grep -m1 -E "^$1:" "$2" | sed -E "s/^$1:[[:space:]]*//" ; }
# grep -i combined with -F crashes (core dump) on the GNU grep 3.0 build in this
# environment's Git Bash -- confirmed reproducible with plain 'echo x | grep -qiF x'.
# Work around it with -E plus manual escaping instead of -F.
grep_fixed_ci() {
  local pat_escaped
  pat_escaped=$(printf '%s' "$1" | sed -E 's/[][\.^$*+?(){}|\\]/\\&/g')
  grep -qiE -- "$pat_escaped"
}

found=0
[ -d "$proc_dir" ] || { echo "find_procedure: no procedures/ directory yet"; exit 3; }

while IFS= read -r -d '' f; do
  [ "$(basename "$f")" = "_INDEX.md" ] && continue

  f_status=$(field "status" "$f")
  [ "$include_draft" -eq 1 ] || [ "$f_status" = "active" ] || continue

  if [ -n "$code" ]; then
    f_codes=$(field "codes" "$f")
    echo "$f_codes" | grep_fixed_ci "$code" || continue
  fi

  if [ -n "$payer" ]; then
    f_payer=$(field "payer" "$f")
    [ "$f_payer" = "$payer" ] || [ "$f_payer" = "any" ] || continue
  fi

  if [ -n "$category" ]; then
    f_category=$(field "category" "$f")
    [ "$f_category" = "$category" ] || continue
  fi

  if [ "${#terms[@]}" -gt 0 ]; then
    f_title=$(field "title" "$f")
    matched=0
    for t in "${terms[@]}"; do
      if echo "$f_title $f_category" | grep -qi -- "$t"; then matched=1; break; fi
    done
    [ "$matched" -eq 1 ] || continue
  fi

  f_id=$(field "id" "$f")
  f_version=$(field "version" "$f")
  f_payer_out=$(field "payer" "$f")
  f_title_out=$(field "title" "$f")
  echo "$f_id | v$f_version | $f_payer_out | $f_title_out | ${f#$repo_root/}"
  found=1
done < <(find "$proc_dir" -type f -name '*.md' -print0)

[ "$found" -eq 1 ] || { echo "find_procedure: no matches"; exit 3; }
