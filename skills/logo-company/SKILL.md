---
name: logo-company
description: "Поиск SVG-логотипа бренда/инструмента/компании в локальной библиотеке (база glincker/thesvg, 5886 брендов, MIT). Возвращает путь к SVG (default или mono) для встраивания в баннеры, обложки, посты. Используй ВСЕГДА когда пользователь упоминает любую компанию/AI-инструмент/бренд – Claude, ChatGPT, Codex, Cursor, OpenAI, Anthropic, Notion, Telegram, MCP, Higgsfield, Gemini, Mistral, Perplexity, Midjourney, GitHub, Firebase, Supabase, Vercel, Hermes, или любой другой brand name – ДАЖЕ ЕСЛИ пользователь не просит явно «найди иконку». Проактивно используй при генерации баннеров, карточек для соцсетей, YouTube-обложек, ТЗ на reels – подставляй real SVG вместо текстовых надписей. Триггеры: «найди лого X», «иконка Y», «логотип Z», «SVG для X», «добавь логотип», «лого компании», «brand icon», или просто упоминание любого бренда в контексте визуального контента. НЕ для: фото людей, нестандартные иллюстрации, AI-арт – только официальные brand SVG."
---

# Logo Company – поиск SVG-логотипов брендов

## Источник

База: [glincker/thesvg](https://github.com/glincker/thesvg) – 5 886 уникальных брендов, 11 624 SVG, MIT-лицензия, npm-пакет `thesvg`. Структура: `public/icons/<slug>/{default,mono,color,dark,light}.svg`.

**Локальный кэш:** `<skill>/_cache/brand-icons/` (каталог `_cache/` внутри папки скилла, переопределяется переменной `LOGO_COMPANY_CACHE`). Изначально пуст, наполняется автоматически по запросу: скачивается только то, что реально понадобилось.

## Когда использовать какой вариант

- **`default.svg`** – фирменные цвета бренда. Использовать в подкастах, YouTube-обложках, full-color баннерах. Кричит «это Claude», «это OpenAI» – узнаётся мгновенно.
- **`mono.svg`** – одноцветный (часто с `fill="currentColor"`). Перекрашивается через CSS `color` в цвет твоей палитры. Минималистично, не ломает палитру.
- **`color.svg`** / **`dark.svg`** / **`light.svg`** – у некоторых брендов есть варианты для тёмного/светлого фона. Использовать когда default или mono не подходят.

**Правило:** в строгом фирменном стиле с ограниченной палитрой – mono. В цветном контенте (YouTube, яркие карточки) – default.

## Процесс

### 1. Поиск иконки

```bash
~/.claude/skills/logo-company/scripts/find-logo.sh <brand-name> [variant]
```

- `<brand-name>` – название бренда. Можно с typo / разным регистром / синонимами (claude, Claude, CLAUDE, claude-code, anthropic, openai-chatgpt).
- `[variant]` – опционально: `default` (по умолчанию), `mono`, `color`, `dark`, `light`.

Скрипт:
1. Ищет в локальном кэше с fuzzy-match (substring + ratio).
2. Если не найден – тянет из raw.githubusercontent с авто-fallback на похожие slugs.
3. Возвращает путь к SVG. Exit 0 = найден, exit 1 = не найден.

### 2. Обновление кэша

```bash
~/.claude/skills/logo-company/scripts/update-cache.sh [brand1] [brand2] ...
```

Без аргументов – обновляет существующий кэш. С аргументами – качает указанные бренды (default + mono варианты).

### 3. Встраивание в HTML

Inline SVG (рекомендуется) – никаких внешних запросов:

```html
<div style="color:#101010; width:48px; height:48px;">
  <!-- содержимое mono.svg вставить сюда -->
</div>
```

Для mono с `fill="currentColor"` – перекраска через родительский CSS `color`. Для других – заменить `fill` атрибуты на `currentColor` через sed.

Паттерны интеграции в шаблоны – в `references/integration-patterns.md`.

## Каталог часто используемых брендов

Полный каталог – `references/brands-catalog.md`. Самые востребованные для контента про AI и разработку:

| Категория | Slug в репо |
|---|---|
| Claude (AI) | `claude`, `claude-ai`, `claude-code`, `anthropic` |
| OpenAI / ChatGPT | `openai`, `openai-chatgpt`, `codex`, `codex-openai`, `dall-e-openai`, `sora-openai` |
| Другие LLM | `google-gemini`, `gemini`, `xai-grok`, `grok`, `mistral-ai`, `mistral`, `metaai`, `deepmind-google` |
| Кодинг-инструменты | `cursor`, `github-copilot`, `vscode` (если есть) |
| MCP / агенты | `mcp-model-context-protocol`, `mcpdotso`, `hermes`, `nousresearch-hermes` |
| Видео-генерация | `runway`, `luma`, `dreammachine-luma`, `kling`, `sora-openai` |
| Поиск / ресёрч | `perplexity`, `perplexity-ai` |
| Изображения | `midjourney`, `dall-e-openai` |
| Соцсети | `telegram`, `instagram`, `threads`, `youtube`, `tiktok`, `x-formerly-twitter`, `twitter` |
| Стек | `notion`, `firebase`, `supabase`, `vercel`, `stripe`, `github`, `figma` |

**Чего нет в репо:** `higgsfield` – нужен собственный SVG (положить в кэш как `higgsfield-mono.svg`).

## Правила работы (важно)

1. **Проактивно** – если пользователь обсуждает что-то связанное с конкретным брендом и идёт работа над визуалом (баннер, обложка, тред) – автоматически подтяни логотип, не жди явного запроса.

2. **Fuzzy match** – у репо есть вариации: `claude` и `claude-code`, `openai` и `openai-chatgpt`. Если уверен в нужном – используй точный slug; если нет – вернуть кандидатов и спросить.

3. **MIT-лицензия** – коммерческое использование разрешено. Credits не обязательны в баннерах, но желательны в credits-страницах сайтов (`Icons from glincker/thesvg, MIT`). Сами логотипы остаются товарными знаками своих владельцев.

4. **Не путать с illustration** – этот скилл только для официальных brand SVG, не для иллюстраций / AI-арта / стикеров. Если нужна иллюстрация – генератор изображений.

5. **mono в строгой палитре** – одноцветные логотипы не ломают дизайн-систему. Цветной default только если бренд узнаваем именно по цвету (Claude #D97757, OpenAI black, etc) и это работает в композиции.

## Интеграции

Скилл работает как поставщик логотипов для любых скиллов, которые генерируют HTML или ТЗ (см. `references/integration-patterns.md`):

- **баннеры** – иконки в footer / «works with» ряду
- **карточки для соцсетей** – логотип рядом с заголовком
- **YouTube-обложки** – hero icon рядом с заголовком
- **ТЗ на reels** – в timeline-блоках «на экране»

## Чего избегать

- Не качать всю библиотеку (11K SVG). Только нужные бренды по запросу.
- Не предлагать иконки, не относящиеся к теме материала.
- Не перерисовывать SVG руками – если бренд есть в репо, использовать оригинал. Перерисовка только для брендов, которых в репо нет (например, `higgsfield`), или для собственных брендов.
