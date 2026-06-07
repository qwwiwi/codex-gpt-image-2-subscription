# Brands Catalog – часто используемые slugs

Список brand slugs в glincker/thesvg, релевантные для AI-контента. Используется find-logo.sh для разрешения имён в slug.

## AI / LLM

| Бренд | Точный slug | Варианты |
|---|---|---|
| Claude | `claude` | default, mono |
| Claude Code | `claude-code` | default, mono |
| Claude AI | `claude-ai` | default, mono |
| Anthropic | `anthropic` | default, mono |
| OpenAI | `openai` | default |
| ChatGPT | `openai-chatgpt` | default, mono |
| Codex | `codex`, `codex-openai` | default, mono |
| DALL-E | `dall-e-openai` | default |
| Sora | `sora-openai` | default |
| Google Gemini | `google-gemini`, `gemini` | default, mono |
| Gemini CLI | `gemini-cli` | default |
| xAI Grok | `xai-grok`, `grok`, `grok-xai` | default |
| Mistral | `mistral`, `mistral-ai` | default, mono |
| Meta AI | `metaai`, `meta` | default |
| DeepMind | `deepmind-google` | default |
| Perplexity | `perplexity`, `perplexity-ai` | default, mono |
| Midjourney | `midjourney` | default |

## Кодинг / агенты

| Бренд | Slug | Варианты |
|---|---|---|
| Cursor | `cursor` | default, mono |
| GitHub Copilot | `github-copilot` | default, mono |
| MCP (Model Context Protocol) | `mcp-model-context-protocol` | default, mono |
| MCP.so | `mcpdotso` | default |
| Hermes (Nous Research) | `hermes`, `nousresearch-hermes` | default, mono |
| GitHub | `github` | default, mono |
| GitHub Actions | `github-actions` | default, mono |
| GitHub Codespaces | `githubcodespaces` | default |

## Видео-генерация

| Бренд | Slug | Варианты |
|---|---|---|
| Runway | `runway` | default |
| Luma Labs | `luma` | default |
| Dream Machine (Luma) | `dreammachine-luma` | default |
| Kling | `kling` | default |
| Sora | `sora-openai` | default |

**Higgsfield** – ОТСУТСТВУЕТ в репо. Нужен наш собственный SVG: положить в `_assets/brand-icons/higgsfield-mono.svg`.

## Соцсети / платформы

| Бренд | Slug | Варианты |
|---|---|---|
| Telegram | `telegram` | default, mono |
| Instagram | `instagram` | default, mono |
| Threads (Meta) | `threads` | default, mono |
| YouTube | `youtube` | default, mono |
| YouTube Shorts | `youtube-shorts` | default |
| TikTok | `tiktok` | default |
| X (Twitter) | `x-formerly-twitter` | default |
| Twitter (legacy) | `twitter` | default |
| Discord | `discord` | default, mono |
| Slack | `slack` | default, mono |

## Стек разработки

| Бренд | Slug | Варианты |
|---|---|---|
| Notion | `notion` | default, mono |
| Firebase | `firebase` | default, mono |
| Firebase Studio | `firebase-studio` | default |
| Supabase | `supabase` | default, mono |
| Vercel | `vercel` | default, mono |
| Vercel v0 | `v0-vercel` | default |
| Stripe | `stripe` | default |
| Figma | `figma` | default |
| Linear | `linear` | default |
| shadcn/ui | `shadcn-ui` | default |
| Tailwind CSS | `tailwind-css` | default |
| TypeScript | `typescript` | default |
| React | `react` | default |
| Next.js (через Vercel) | `vercel` | default |

## Облако / инфра

| Бренд | Slug | Варианты |
|---|---|---|
| AWS | `aws` | default |
| Google Cloud | префикс `gcp-*` | разные |
| Azure | префикс `azure-*` | разные |
| Docker | `docker` | default |

## Принципы разрешения имён

1. **Точное совпадение slug** побеждает (`claude` → `claude`).
2. **Префикс-совпадение** второй приоритет (`claude` → `claude-code` если запрос «claude code»).
3. **Substring fuzzy** на крайний случай (3 кандидата возвращаются).
4. **Если бренд имеет owner-prefix** (например `openai-chatgpt`, `nousresearch-hermes`) – запрос «chatgpt» резолвится в `openai-chatgpt`, не в `chatgpt`.

## Полный список

`<skill>/_cache/brand-icons/.brand-list.txt` – локально кэшированный полный список из 5886 slugs. Обновляется автоматически каждые 24h через find-logo.sh при необходимости.
