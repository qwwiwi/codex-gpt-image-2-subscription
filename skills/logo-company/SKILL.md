---
name: logo-company
description: Use when a brand, company or AI-tool logo is needed for a banner, cover, post or composite (найди лого X, иконка Y, логотип Z, add brand icon, логотип компании) — Claude, ChatGPT, Codex, OpenAI, Anthropic, Cursor, Telegram, GitHub, Notion, Gemini, Perplexity, Midjourney or any other brand. Looks up the official SVG in a local library (glincker/thesvg, 5886 brands, MIT) and returns a file path (default or mono variant). NOT for: photos of people, custom illustrations, AI-art — official brand SVGs only.
---

# logo-company — official brand SVG lookup

## Source

Base: [glincker/thesvg](https://github.com/glincker/thesvg) — 5 886 brands, 11 624 SVGs, MIT license. Structure: `public/icons/<slug>/{default,mono,color,dark,light}.svg`.

Local cache: `<skill>/_cache/brand-icons/` — populated automatically on first request.

## Which variant

- **`default.svg`** — official brand colors. Use in full-color banners, covers, posts. Instantly recognizable.
- **`mono.svg`** — single-color, usually `fill="currentColor"`. Use on styled backgrounds — recolor to any accent via CSS `color` or by substituting the fill. Minimal, never breaks your palette.
- **`color.svg` / `dark.svg` / `light.svg`** — some brands ship variants for dark/light backgrounds.

## Process

### 1. Find a logo

```bash
<skill>/scripts/find-logo.sh <brand-name> [variant]
```

- `<brand-name>` — tolerant to typos / case / synonyms (claude, Claude, claude-code, anthropic, openai-chatgpt).
- `[variant]` — optional: `default` (default), `mono`, `color`, `dark`, `light`.

The script searches the local cache with fuzzy-match, falls back to raw.githubusercontent with slug auto-resolution, prints the SVG path. Exit 0 = found, exit 1 = not found.

### 2. Refresh the cache

```bash
<skill>/scripts/update-cache.sh [brand1] [brand2] ...
```

### 3. Use the SVG

- **Composite onto a generated image:** wrap the banner PNG + the logo path in an SVG and render to PNG (e.g. `@resvg/resvg-js`). For `mono` recolor by replacing `currentColor`.
- **As a generation reference:** pass the rendered logo PNG as a reference image to the `codex-image` skill — gpt-image-2 will carry the mark into the artwork.
- **Inline in HTML:** paste mono SVG inside a `<div style="color:#D4FF00">` — `currentColor` picks up the accent.

## Frequently used slugs

Full catalog: `references/brands-catalog.md`. Highlights:

| Category | Slugs |
|---|---|
| Claude / Anthropic | `claude`, `claude-ai`, `claude-code`, `anthropic` |
| OpenAI | `openai`, `openai-chatgpt`, `codex-openai`, `dall-e-openai`, `sora-openai` |
| Other LLMs | `google-gemini`, `xai-grok`, `mistral-ai`, `deepmind-google` |
| Coding tools | `cursor`, `github-copilot` |
| Social | `telegram`, `instagram`, `youtube`, `tiktok`, `x-formerly-twitter` |
| Stack | `notion`, `firebase`, `supabase`, `vercel`, `github`, `figma` |

## Rules

- Prefer the official SVG over re-drawing or AI-generating a brand mark — trademarks must be exact.
- `mono` on styled backgrounds, `default` in full-color contexts.
- Respect each brand's usage guidelines when publishing.
