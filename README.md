# Мой AstroNvim конфиг

Этот репозиторий содержит персональную настройку AstroNvim 5 с упором на Go и YAML. Основные плагины и улучшения включают Catppuccin, Noice, Trouble, Copilot, а также расширенную поддержку Go (go.nvim, nvim-dap-go) и YAML (yaml-companion).

## Основные фичи
- Автосохранение при выходе из режима вставки и переключении режимов (если буфер изменён и доступен для записи).
- Автоматическое сохранение Go файлов при наличии активного `gopls`.
- Встроенный нижний терминал ToggleTerm, открывающийся по Ctrl+,.
- Стабильные LSP inlay hints с единым переключателем и совместимостью разных API Neovim.

## Пользовательские хоткеи

### Глобальные сочетания
| Комбинация | Описание |
| --- | --- |
| `<C-c>` (вставка) | Ведёт себя как `<Esc>`, чтобы срабатывали автокоманды выхода из режима вставки |
| `<C-,>` | Переключить нижний терминал ToggleTerm |
| `<leader>uh` | Вкл/выкл LSP inlay hints в текущем буфере |
| `<leader>ua` | Переключить автоподсказки GitHub Copilot |
| `<leader>sp` | Открыть Copilot Panel |
| `<leader>fp` | Смена проекта через Telescope Projects |
| `<leader>xd` | Панель Diagnostics (Trouble) |
| `<leader>xl` | Локальный список (Trouble) |
| `<leader>xt` | Todo Trouble |
| `<leader>sm` | История сообщений (Noice) |
| `<leader>sn` | Скрыть сообщения (Noice) |

### Горячие клавиши для Go файлов
Эти сочетания активируются только для буферов Go (`go`, `gomod`, `gowork`).

| Комбинация | Команда |
| --- | --- |
| `<leader>ct` | `GoTest` — тестировать пакет |
| `<leader>cT` | `GoTestFunc` — тестировать текущую функцию |
| `<leader>cr` | `GoRun` — запустить модуль |
| `<leader>cb` | `GoBuild` — собрать пакет |
| `<leader>ci` | `GoIfErr` — вставить сниппет if err |
| `<leader>cA` | `GoAddTag` — добавить теги к структурам (запросит тип тега) |
| `<leader>cR` | `GoRmTag` — удалить теги у структур (запросит тип тега) |

## Поддержка YAML
`yaml-companion` настроен только для общих YAML-файлов без особых матчеров под Kubernetes. LSP `yamlls` подключается с расширением схем из Telescope (`:Telescope yaml_schema`).

## Установка
1. Создайте бэкап текущей конфигурации Neovim.
2. Клонируйте репозиторий в `~/.config/nvim`.
3. Запустите `nvim` и дождитесь установки плагинов.

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak

git clone https://github.com/<user>/<repo> ~/.config/nvim
nvim
```

## Лицензия
MIT
