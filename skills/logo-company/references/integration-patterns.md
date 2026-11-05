# Integration Patterns – как встраивать SVG в свои скиллы и шаблоны

Цвета в примерах (`#101010`, `#545454`) условные – подставь токены своей дизайн-системы.

## 1. Inline SVG в HTML (предпочтительно)

Подходит для любых HTML-шаблонов: баннеры, карточки для соцсетей, обложки.

**Mono с currentColor (для строгой палитры):**
```html
<style>
  .brand-icon { width: 48px; height: 48px; color: #101010; }
</style>
<div class="brand-icon">
  <!-- содержимое mono.svg вставить целиком -->
</div>
```

Большинство mono-вариантов в репо имеют `fill="currentColor"`, поэтому CSS `color` управляет цветом. Для тех, где fill жёстко задан, переопределить через sed:

```bash
sed 's/fill="#[0-9a-fA-F]*"/fill="currentColor"/g' input.svg > output.svg
```

**Default с фирменным цветом (для colored content):**
```html
<div style="width:64px; height:64px;">
  <!-- содержимое default.svg, оставить как есть -->
</div>
```

## 2. Pattern: works-with row

Используется в баннерах и footer-секциях. 2-4 иконки с подписями в ряд.

```html
<style>
.works-row {
  display: flex; align-items: center; gap: 32px;
  color: #101010;
}
.works-row .brand {
  display: flex; flex-direction: column; align-items: center; gap: 8px;
}
.works-row .brand svg {
  width: 42px; height: 42px; color: #101010;
}
.works-row .brand .label {
  font-size: 12px; letter-spacing: 2px; text-transform: uppercase;
  color: #545454;
}
.works-row .sep {
  width: 5px; height: 5px; background: #101010;
  border-radius: 50%; opacity: 0.5;
}
</style>

<div class="works-row">
  <div class="brand">
    <!-- codex-openai-mono.svg -->
    <span class="label">Codex</span>
  </div>
  <span class="sep"></span>
  <div class="brand">
    <!-- claude-code-mono.svg -->
    <span class="label">Claude Code</span>
  </div>
  <span class="sep"></span>
  <div class="brand">
    <!-- hermes-mono.svg -->
    <span class="label">Hermes</span>
  </div>
</div>
```

## 3. Pattern: hero icon в YouTube-обложке

YouTube cover 1280×720: крупная иконка слева от заголовка.

```html
<div class="hero" style="display:flex; align-items:center; gap:48px;">
  <div style="width:200px; height:200px; color:#101010;">
    <!-- claude-code-mono.svg или default – зависит от стиля -->
  </div>
  <div class="title-block">
    <h1>MCP в Claude Code</h1>
    <p>5 серверов, которые меняют всё</p>
  </div>
</div>
```

## 4. Pattern: timeline-блок в ТЗ на reels

В timeline-блоке монтажёру указывается какой логотип нужен на экране:

```html
<div class="tip-card">
  <div class="tip-label">На экране</div>
  <div style="display:flex; align-items:center; gap:12px;">
    <div style="width:32px; height:32px; color:#101010;">
      <!-- claude-code-mono.svg -->
    </div>
    <span>Терминал Claude Code, команда /goal в действии.</span>
  </div>
</div>
```

## 5. Bash snippet для скилла-консьюмера

Любой другой скилл, который генерирует HTML, использует find-logo.sh так:

```bash
LOGO_SH="$HOME/.claude/skills/logo-company/scripts/find-logo.sh"

# Получить путь к SVG
CLAUDE_SVG=$("$LOGO_SH" claude-code mono)
CODEX_SVG=$("$LOGO_SH" codex mono)

# Вставить содержимое в HTML
CLAUDE_CONTENT=$(cat "$CLAUDE_SVG")
CODEX_CONTENT=$(cat "$CODEX_SVG")

# или прямо в шаблон через sed/python templating
```

## 6. Когда default vs mono vs цветной

| Контекст | Вариант | Причина |
|---|---|---|
| Баннер в строгой фирменной палитре | mono → основной цвет текста | Палитра не ломается, минимализм |
| YouTube обложка цветная | default | Узнаваемость бренда, контраст |
| Яркая карточка для соцсетей | default | Эмоциональный/яркий контент |
| Сдержанная карточка | mono → mute color | Аскетичный, не отвлекает |
| ТЗ на reels для монтажёра | mono | Монтажёр сам адаптирует |
| Логотипы партнёров / клиентов | default | Уважение к их brand identity |

## 7. Placeholder-ы в шаблонах

Чтобы скилл-генератор баннеров автоматически вставлял иконки в свой HTML-шаблон:

1. Добавить в шаблон placeholder: `<!-- LOGO:claude-code:mono -->`
2. В скрипте рендера после загрузки HTML pre-processor заменяет placeholders на содержимое SVG через find-logo.sh.

Pre-processor pattern:
```python
import re, subprocess
from pathlib import Path

FIND_LOGO = str(Path.home() / ".claude/skills/logo-company/scripts/find-logo.sh")

def inject_logos(html):
    pattern = re.compile(r'<!-- LOGO:([\w-]+):(\w+) -->')
    def repl(m):
        brand, variant = m.group(1), m.group(2)
        result = subprocess.run(
            [FIND_LOGO, brand, variant],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            return open(result.stdout.strip()).read()
        return f'<!-- LOGO_MISS:{brand} -->'
    return pattern.sub(repl, html)
```
