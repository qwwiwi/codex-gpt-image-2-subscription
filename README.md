# codex-gpt-image-2-subscription

**Генерация картинок моделью gpt-image-2 по подписке ChatGPT/Codex — без API-ключа и поштучной оплаты.**

[English version](README.en.md)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Python 3.10+](https://img.shields.io/badge/Python-3.10%2B-blue)
![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-Skill-orange)

Готовый скилл для Claude Code: агент генерирует изображения (включая генерацию **по референсам** — до 5 входных картинок) через ту же OAuth-авторизацию, которой пользуется Codex CLI.

## Это НЕ API

Здесь нет `OPENAI_API_KEY` и нет оплаты за каждую картинку. Всё работает **в рамках подписки ChatGPT (Plus/Pro)** — той самой, под которой залогинен Codex CLI. Скрипт берёт OAuth-токен из `~/.codex/auth.json` и ходит в бэкенд Codex (`chatgpt.com/backend-api/codex`) через Responses API: host-модель gpt-6-astra вызывает инструмент `image_generation`, рисует gpt-image-2. Квота общая с подпиской.

## Демо: генерация по референсу

Модели передаётся картинка-референс и текстовый промпт — персонаж и стиль сохраняются в новой сцене.

| Референс | «character DJ-ing at a turntable» | «character ice-fishing, cozy winter» |
|:---:|:---:|:---:|
| ![reference](examples/reference.png) | ![dj](examples/result-dj.png) | ![fishing](examples/result-fishing.png) |

## Установка

### Шаг 1 — Codex CLI + логин подпиской

```bash
npm install -g @openai/codex
codex login                  # на сервере без браузера: codex login --device-auth
```

Логин создаёт `~/.codex/auth.json` — это и есть доступ по подписке. API-ключ не нужен.

### Шаг 2 (рекомендуется) — Codex-плагин для Claude Code

Официальный плагин OpenAI, чтобы Claude Code умел делегировать задачи и ревью в Codex: **[openai/codex-plugin-cc](https://github.com/openai/codex-plugin-cc)**

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
```

Сам плагин картинки **не** генерирует (его роль — код-ревью и задачи), но связка «плагин + этот скилл» закрывает обе потребности на одной подписке.

### Шаг 3 — скилл

```bash
git clone https://github.com/qwwiwi/codex-gpt-image-2-subscription
cp -r codex-gpt-image-2-subscription/skills/codex-image ~/.claude/skills/
```

Готово. Теперь в Claude Code достаточно сказать «сгенерируй картинку …» / «сделай вариант по этому референсу …» — скилл подхватится сам. Python-зависимости ставить не надо: лаунчер при первом запуске сам поднимает виртуальное окружение.

## Использование

```bash
~/.claude/skills/codex-image/scripts/run.sh \
  "prompt на английском" [quality] [aspect] [ref1.png ... ref5.png]
```

| Параметр | Значения | Примечание |
|---|---|---|
| `quality` | `low` (~45 сек) / `medium` (по умолчанию) / `high` (~2-3 мин) | |
| `aspect` | `landscape` 1536x1024 / `square` 1024x1024 / `portrait` 1024x1536 | |
| референсы | до 5 путей к png/jpg/webp | ≤15 MB каждый, ≤40 MB суммарно |
| вывод | путь к готовому PNG | `~/.codex/cache/images/img_<ts>.png` |

Примеры:

```bash
# просто текстом
run.sh "neon crab DJ, cyberpunk style" high square

# по референсу: персонаж/стиль/лого переносятся в новую сцену
run.sh "same character riding a snowboard, same flat style" medium landscape ./avatar.png

# референс можно передать и без quality/aspect — скрипт сам поймёт, что это файл
run.sh "same character as a chef" ./avatar.png
```

## Как это устроено

```
prompt + референсы (input_image, data URL)
        │
        ▼
Responses API  ──  chatgpt.com/backend-api/codex  (OAuth из ~/.codex/auth.json)
        │
        ▼
host-модель gpt-6-astra ── tool_choice: image_generation ──► gpt-image-2
        │
        ▼
SSE-поток ──► PNG на диск
```

Нюансы, выстраданные практикой (всё уже учтено в скрипте):

- `stream=True` и `store=False` обязательны — иначе HTTP 400
- `client.images.generate()` через подписку не работает — только Responses API + tool
- референсы — content-блоки `{"type": "input_image", "image_url": "data:<mime>;base64,...", "detail": "auto"}` рядом с текстом промпта в одном сообщении
- `tool_choice={"type": "image_generation"}` заставляет модель рисовать сразу
- seed-параметра нет: для строгой воспроизводимости нужен платный API с seed; для переноса персонажа/стиля/лого хватает референсов

## Бонус: skill logo-company — официальные SVG-логотипы брендов

В комплекте второй скилл: поиск официального SVG-логотипа любого бренда (Claude, OpenAI, Codex, Telegram, GitHub — база [glincker/thesvg](https://github.com/glincker/thesvg), 5 886 брендов, MIT).

```bash
cp -r codex-gpt-image-2-subscription/skills/logo-company ~/.claude/skills/

~/.claude/skills/logo-company/scripts/find-logo.sh codex mono
# → путь к SVG: впаивай в баннер, перекрашивай под палитру или отдавай
#   референсом в codex-image
```

Связка двух скиллов: `find-logo.sh` достаёт фирменный знак → рендеришь его поверх сгенерированной картинки (или передаёшь референсом) — товарный знак остаётся точным, а не «примерно похожим от нейросети».

## Структура репозитория

```
codex-gpt-image-2-subscription/
├── README.md                      # этот файл
├── README.en.md                   # English version
├── LICENSE                        # MIT
├── examples/                      # демо: референс и результаты
│   ├── reference.png
│   ├── result-dj.png
│   └── result-fishing.png
└── skills/
    ├── codex-image/               # генерация картинок — в ~/.claude/skills/
    │   ├── SKILL.md               # инструкция для агента (триггеры, ограничения)
    │   └── scripts/
    │       ├── run.sh             # лаунчер: сам поднимает venv и запускает
    │       └── codex_image.py     # генератор (Responses API + image_generation)
    └── logo-company/              # поиск официальных brand-SVG (thesvg, 5886 брендов)
        ├── SKILL.md
        ├── references/brands-catalog.md
        └── scripts/
            ├── find-logo.sh       # fuzzy-поиск логотипа, локальный кэш
            └── update-cache.sh
```

## Troubleshooting

| Симптом | Решение |
|---|---|
| `Codex auth не найден` | `codex login` (сервер: `codex login --device-auth`) |
| `ModuleNotFoundError: openai` | запускать через `run.sh`, не системным python3 |
| HTTP 400 | проверь stream=True, store=False |
| 401/403 | токен протух — повторный `codex login` |
| Картинка не пришла | модель отказалась (policy) — переформулируй промпт |

## Благодарности

Техника передачи референсов через Codex-бэкенд — из репозитория [ningzimu/codex-gpt-image](https://github.com/ningzimu/codex-gpt-image).

## Лицензия

MIT
