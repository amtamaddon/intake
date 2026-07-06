#!/usr/bin/env bash
# The only sanctioned way to update MEMORY.md. Validates the cap and the required
# per-bullet [source | date] suffix, then installs atomically. Direct Write/Edit on
# MEMORY.md is permission-denied in .claude/settings.json; this script is the door.
# Usage: memory_update.sh <staged-file>
#   <staged-file> is the FULL proposed new MEMORY.md (header + all sections),
#   written to a scratch path by the caller (normally /close-session).
set -euo pipefail
staged="${1:?usage: memory_update.sh <staged-file>}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$repo_root/MEMORY.md"
CAP=4000

[ -f "$staged" ] || { echo "memory_update: no such file: $staged"; exit 1; }
grep -q '^# MEMORY' "$staged" || { echo "memory_update: REFUSED — missing '# MEMORY' header"; exit 1; }

size=$(wc -c < "$staged")
if [ "$size" -gt "$CAP" ]; then
  echo "memory_update: REFUSED — $size/$CAP chars. Evict oldest-last-confirmed bullets first:"
  grep -oE '\[[^]]+\]' "$staged" | sort -t'|' -k2 || true
  exit 1
fi

# The Pointers section is exempt: it holds where-to-look references, not dated
# facts, so it carries no [source | date] tag by design.
non_pointer_bullets=$(awk '/^## Pointers/{skip=1} /^## / && !/^## Pointers/{skip=0} skip{next} /^- /{print}' "$staged")
bad=$(printf '%s\n' "$non_pointer_bullets" | grep -vcE '\[[^]]+\]$' || true)
if [ -n "$non_pointer_bullets" ] && [ "${bad:-0}" -gt 0 ]; then
  echo "memory_update: REFUSED — $bad bullet(s) missing a trailing [source | date] tag"
  printf '%s\n' "$non_pointer_bullets" | grep -vE '\[[^]]+\]$' || true
  exit 1
fi

stamped=$(mktemp)
sed -E "s|^Last updated:.*|Last updated: $(date -u +%Y-%m-%d) \\| Size: ${size}/${CAP} chars|" "$staged" > "$stamped"
mv "$stamped" "$target"
echo "memory_update: OK — ${size}/${CAP} chars"
