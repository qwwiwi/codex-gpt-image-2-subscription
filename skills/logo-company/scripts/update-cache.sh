#!/usr/bin/env bash
# update-cache.sh — refresh brand-icons local cache.
#
# Usage:
#   update-cache.sh                  # re-download all currently cached brands
#   update-cache.sh brand1 brand2    # add new brands (default + mono variants)
#
# Tries default + mono variants. Skips on 404 (variant doesn't exist).

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_DIR="$SKILL_DIR/_cache/brand-icons"
REMOTE_BASE="https://raw.githubusercontent.com/glincker/thesvg/main/public/icons"
BRAND_LIST_CACHE="$CACHE_DIR/.brand-list.txt"

mkdir -p "$CACHE_DIR"

# Build list of brands to refresh
if [ $# -gt 0 ]; then
    # New brands from args
    BRANDS=("$@")
else
    # Re-fetch existing cached brands
    BRANDS=()
    for f in "$CACHE_DIR"/*-default.svg "$CACHE_DIR"/*-mono.svg; do
        [ -f "$f" ] || continue
        name=$(basename "$f" .svg)
        # strip trailing -default or -mono
        slug="${name%-default}"
        slug="${slug%-mono}"
        BRANDS+=("$slug")
    done
    # Deduplicate
    BRANDS=($(printf '%s\n' "${BRANDS[@]}" | sort -u))
fi

if [ ${#BRANDS[@]} -eq 0 ]; then
    echo "no brands to update (empty cache, pass slugs as args)" >&2
    exit 1
fi

echo "[update-cache] refreshing ${#BRANDS[@]} brands..."

OK=0
SKIP=0
FAIL=0

for brand in "${BRANDS[@]}"; do
    norm=$(echo "$brand" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | tr -d '.')
    for variant in default mono; do
        url="${REMOTE_BASE}/${norm}/${variant}.svg"
        out="${CACHE_DIR}/${norm}-${variant}.svg"

        http=$(curl -sS -o "$out.tmp" -w "%{http_code}" -L "$url")
        size=$(stat -c "%s" "$out.tmp" 2>/dev/null || stat -f "%z" "$out.tmp" 2>/dev/null || echo 0)

        if [ "$http" = "200" ] && [ "$size" -gt 100 ]; then
            mv "$out.tmp" "$out"
            OK=$((OK+1))
            echo "  ok:   $norm/$variant ($size bytes)"
        elif [ "$http" = "404" ]; then
            rm -f "$out.tmp"
            SKIP=$((SKIP+1))
        else
            rm -f "$out.tmp"
            FAIL=$((FAIL+1))
            echo "  fail: $norm/$variant (http=$http)"
        fi
    done
done

# Refresh brand list TTL too
rm -f "$BRAND_LIST_CACHE"

echo ""
echo "[update-cache] done. ok=$OK skip=$SKIP fail=$FAIL"
echo "[update-cache] cache: $CACHE_DIR"
