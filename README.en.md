# codex-gpt-image-2-subscription

**Generate images with gpt-image-2 on your ChatGPT/Codex subscription — no API key, no per-image billing.**

[Русская версия](README.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue)
![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-orange)

A ready-made Claude Code skill: the agent generates images (including **reference-based** generation — up to 5 input images) through the same OAuth login Codex CLI uses.

## This is NOT the API

No `OPENAI_API_KEY`, no per-image charges. Everything runs **within your ChatGPT subscription (Plus/Pro)** — the one Codex CLI is logged into. The script reads the OAuth token from `~/.codex/auth.json` and calls the Codex backend (`chatgpt.com/backend-api/codex`) over the Responses API: the latest frontier GPT model (default gpt-6-astra) invokes the `image_generation` tool, gpt-image-2 renders. Quota is shared with the subscription.

## Demo: reference-based generation

Pass a reference image alongside the text prompt — the character and style carry over into a new scene.

| Reference | "character DJ-ing at a turntable" | "character ice-fishing, cozy winter" |
|:---:|:---:|:---:|
| ![reference](examples/reference.png) | ![dj](examples/result-dj.png) | ![fishing](examples/result-fishing.png) |

## Install

### Step 1 — Codex CLI + subscription login

```bash
npm install -g @openai/codex
codex login                  # headless server: codex login --device-auth
```

The login creates `~/.codex/auth.json` — that file IS your subscription access. No API key needed.

### Step 2 (recommended) — Codex plugin for Claude Code

OpenAI's official plugin so Claude Code can delegate tasks and reviews to Codex: **[openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc)**

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
```

The plugin itself does **not** generate images (its job is code review and tasks), but the "plugin + this skill" combo covers both needs on a single subscription.

### Step 3 — the skill

```bash
git clone https://github.com/qwwiwi/codex-gpt-image-2-subscription
cp -r codex-gpt-image-2-subscription/skills/codex-image ~/.claude/skills/
```

Done. In Claude Code just say "generate an image of …" / "make a variant from this reference …" — the skill triggers on its own. No Python deps to install: the launcher bootstraps its own virtualenv on first run.

## Usage

```bash
~/.claude/skills/codex-image/scripts/run.sh \
  "prompt in English" [quality] [aspect] [ref1.png ... ref5.png]
```

| Param | Values | Notes |
|---|---|---|
| `quality` | `low` (~45s) / `medium` (default) / `high` (~2-3min) | |
| `aspect` | `landscape` 1536x1024 / `square` 1024x1024 / `portrait` 1024x1536 | |
| refs | up to 5 png/jpg/webp paths | ≤15 MB each, ≤40 MB total |
| output | prints the PNG path | `~/.codex/cache/images/img_<ts>.png` |

Examples:

```bash
# text only
run.sh "neon crab DJ, cyberpunk style" high square

# with a reference: character/style/logo transfer into a new scene
run.sh "same character riding a snowboard, same flat style" medium landscape ./avatar.png

# a reference without quality/aspect also works — file args are auto-detected
run.sh "same character as a chef" ./avatar.png
```

## How it works

```
prompt + references (input_image, data URL)
        │
        ▼
Responses API  ──  chatgpt.com/backend-api/codex  (OAuth from ~/.codex/auth.json)
        │
        ▼
frontier GPT model ── tool_choice: image_generation ──► gpt-image-2
        │
        ▼
SSE stream ──► PNG on disk
```

Hard-won gotchas (already handled by the script):

- `stream=True` and `store=False` are mandatory — otherwise HTTP 400
- `client.images.generate()` does not work over the subscription — Responses API + tool only
- references are content blocks `{"type": "input_image", "image_url": "data:<mime>;base64,...", "detail": "auto"}` next to the prompt text in one message
- `tool_choice={"type": "image_generation"}` makes the model draw immediately
- there is no seed parameter: for strict reproducibility you still need a paid API with seed support; for character/style/logo transfer references are enough

## Bonus: logo-company skill — official brand SVG logos

A second skill ships in this repo: official SVG logo lookup for any brand (Claude, OpenAI, Codex, Telegram, GitHub — powered by [glincker/thesvg](https://github.com/glincker/thesvg), 5,886 brands, MIT).

```bash
cp -r codex-gpt-image-2-subscription/skills/logo-company ~/.claude/skills/

~/.claude/skills/logo-company/scripts/find-logo.sh codex mono
# → SVG path: composite onto banners, recolor to your palette,
#   or feed as a reference into codex-image
```

The two skills combine: `find-logo.sh` fetches the exact brand mark → you composite it over the generated artwork (or pass it as a reference) — the trademark stays exact instead of "roughly similar by a neural net".

## Repository structure

```
codex-gpt-image-2-subscription/
├── README.md                      # Russian version
├── README.en.md                   # this file
├── LICENSE                        # MIT
├── examples/                      # demo: reference and results
│   ├── reference.png
│   ├── result-dj.png
│   └── result-fishing.png
└── skills/
    ├── codex-image/               # image generation — copy into ~/.claude/skills/
    │   ├── SKILL.md               # agent instructions (triggers, constraints)
    │   └── scripts/
    │       ├── run.sh             # launcher: bootstraps venv and runs
    │       └── codex_image.py     # generator (Responses API + image_generation)
    └── logo-company/              # official brand SVG lookup (thesvg, 5,886 brands)
        ├── SKILL.md
        ├── references/brands-catalog.md
        └── scripts/
            ├── find-logo.sh       # fuzzy logo search with a local cache
            └── update-cache.sh
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Codex auth not found` | `codex login` (server: `codex login --device-auth`) |
| `ModuleNotFoundError: openai` | run via `run.sh`, not system python3 |
| HTTP 400 | check stream=True, store=False |
| 401/403 | token expired — re-run `codex login` |
| No image returned | model refused (policy) — rephrase the prompt |

## Credits

The reference-image technique over the Codex backend comes from [ningzimu/codex-gpt-image](https://github.com/ningzimu/codex-gpt-image).

## License

MIT
