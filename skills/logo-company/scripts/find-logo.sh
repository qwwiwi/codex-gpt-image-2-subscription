#!/usr/bin/env bash
# find-logo.sh — locate a brand SVG by name, with fuzzy match and auto-download fallback.
#
# Usage:
#   find-logo.sh <brand-name> [variant]
#
# Variants: default (default), mono, color, dark, light
# Returns absolute path to SVG on stdout. Exit 0 = found, exit 1 = not found.

set -uo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Cache dir: $LOGO_COMPANY_CACHE or <skill>/_cache/brand-icons
CACHE_DIR="${LOGO_COMPANY_CACHE:-$SKILL_DIR/_cache/brand-icons}"
REMOTE_BASE="https://raw.githubusercontent.com/glincker/thesvg/main/public/icons"
REPO_TREE_API="https://api.github.com/repos/glincker/thesvg/git/trees/main?recursive=1"
BRAND_LIST_CACHE="$CACHE_DIR/.brand-list.txt"
BRAND_LIST_TTL=86400  # 24h

BRAND="${1:-}"
VARIANT="${2:-default}"

if [ -z "$BRAND" ]; then
    echo "usage: $0 <brand-name> [default|mono|color|dark|light]" >&2
    exit 2
fi

mkdir -p "$CACHE_DIR"

# Normalize: lowercase, replace spaces/underscores with dashes
NORM=$(echo "$BRAND" | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | tr -d '.')

# ---------------------------------------------------------------------------
# 1) Try direct hit in local cache
# ---------------------------------------------------------------------------
DIRECT="$CACHE_DIR/${NORM}-${VARIANT}.svg"
if [ -s "$DIRECT" ]; then
    echo "$DIRECT"
    exit 0
fi

# ---------------------------------------------------------------------------
# 2) Local fuzzy match against cached files (only for queries >= 4 chars)
# ---------------------------------------------------------------------------
# Short queries like "fi" or "ai" match too many brands and produce garbage.
# Tier-1 direct hit above handles short slugs that exist as exact names.
if [ ${#NORM} -ge 4 ]; then
    LOCAL_MATCH=$(ls "$CACHE_DIR"/*-${VARIANT}.svg 2>/dev/null | \
        grep -i "$NORM" | head -1)
    if [ -n "$LOCAL_MATCH" ]; then
        echo "$LOCAL_MATCH"
        exit 0
    fi

    # Variant fallback: if user asked mono and only default exists locally — return default
    if [ "$VARIANT" != "default" ]; then
        LOCAL_ANY=$(ls "$CACHE_DIR"/*-default.svg 2>/dev/null | grep -i "$NORM" | head -1)
        if [ -n "$LOCAL_ANY" ]; then
            echo "$LOCAL_ANY"
            exit 0
        fi
    fi
fi

# ---------------------------------------------------------------------------
# 3) Refresh brand list from GitHub tree API if stale
# ---------------------------------------------------------------------------
NOW=$(date +%s)
LIST_MTIME=0
if [ -f "$BRAND_LIST_CACHE" ]; then
    LIST_MTIME=$(stat -c "%Y" "$BRAND_LIST_CACHE" 2>/dev/null || stat -f "%m" "$BRAND_LIST_CACHE" 2>/dev/null || echo 0)
fi
AGE=$((NOW - LIST_MTIME))

if [ "$AGE" -gt "$BRAND_LIST_TTL" ] || [ ! -s "$BRAND_LIST_CACHE" ]; then
    echo "[find-logo] refreshing brand list..." >&2
    curl -sS "$REPO_TREE_API" 2>/dev/null | \
        python3 -c "
import json,sys,re
try:
    d = json.load(sys.stdin)
    brands = set()
    for it in d.get('tree', []):
        m = re.match(r'public/icons/([^/]+)/', it.get('path',''))
        if m: brands.add(m.group(1))
    for b in sorted(brands): print(b)
except Exception as e:
    sys.stderr.write(f'list refresh failed: {e}\n')
    sys.exit(1)
" > "$BRAND_LIST_CACHE.tmp" && mv "$BRAND_LIST_CACHE.tmp" "$BRAND_LIST_CACHE"
fi

# ---------------------------------------------------------------------------
# 4) Fuzzy match against full brand list
# ---------------------------------------------------------------------------
if [ ! -s "$BRAND_LIST_CACHE" ]; then
    echo "[find-logo] brand list unavailable, cannot fuzzy-match" >&2
    exit 1
fi

# Exact match first, then substring, then loose
CANDIDATES=$(python3 <<PY
import sys
norm = "$NORM"
with open("$BRAND_LIST_CACHE") as f:
    brands = [l.strip() for l in f if l.strip()]

# Tier 1: exact slug
if norm in brands:
    print(norm); sys.exit()

# Tier 2: brand starts with norm or norm starts with brand
exact_prefix = [b for b in brands if b == norm or b.split('-')[0] == norm]
if exact_prefix:
    print(exact_prefix[0]); sys.exit()

# Tier 3: substring match. Require min 4 chars to avoid noise (e.g. "fi" matching everything).
# Only norm-in-brand direction — brand-in-norm gives garbage like "fi" matching "higgsfield".
if len(norm) >= 4:
    subs = [b for b in brands if norm in b]
    # Rank: closer length = more specific
    subs.sort(key=lambda b: (abs(len(b) - len(norm)), len(b)))
    for b in subs[:3]:
        print(b)
PY
)

if [ -z "$CANDIDATES" ]; then
    echo "[find-logo] no match for '$BRAND' (norm: '$NORM')" >&2
    exit 1
fi

# Take top candidate
TOP=$(echo "$CANDIDATES" | head -1)

# ---------------------------------------------------------------------------
# 5) Download to cache
# ---------------------------------------------------------------------------
TARGET="$CACHE_DIR/${TOP}-${VARIANT}.svg"
URL="${REMOTE_BASE}/${TOP}/${VARIANT}.svg"

HTTP=$(curl -sS -o "$TARGET.tmp" -w "%{http_code}" -L "$URL")
SIZE=$(stat -c "%s" "$TARGET.tmp" 2>/dev/null || stat -f "%z" "$TARGET.tmp" 2>/dev/null || echo 0)

if [ "$HTTP" = "200" ] && [ "$SIZE" -gt 100 ]; then
    mv "$TARGET.tmp" "$TARGET"
    echo "$TARGET"
    exit 0
fi

rm -f "$TARGET.tmp"

# Variant fallback to default
if [ "$VARIANT" != "default" ]; then
    DEFAULT_TARGET="$CACHE_DIR/${TOP}-default.svg"
    DEFAULT_URL="${REMOTE_BASE}/${TOP}/default.svg"
    HTTP2=$(curl -sS -o "$DEFAULT_TARGET.tmp" -w "%{http_code}" -L "$DEFAULT_URL")
    SIZE2=$(stat -c "%s" "$DEFAULT_TARGET.tmp" 2>/dev/null || stat -f "%z" "$DEFAULT_TARGET.tmp" 2>/dev/null || echo 0)
    if [ "$HTTP2" = "200" ] && [ "$SIZE2" -gt 100 ]; then
        mv "$DEFAULT_TARGET.tmp" "$DEFAULT_TARGET"
        echo "[find-logo] variant '$VARIANT' missing for '$TOP', returning default" >&2
        echo "$DEFAULT_TARGET"
        exit 0
    fi
    rm -f "$DEFAULT_TARGET.tmp"
fi

echo "[find-logo] download failed for '$TOP' ($URL, http=$HTTP)" >&2
echo "[find-logo] candidates: $(echo $CANDIDATES | tr '\n' ' ')" >&2
exit 1
