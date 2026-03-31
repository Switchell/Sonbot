# Bot (n8n + Qdrant)

Локальный проект для запуска n8n и Qdrant в отдельном Docker compose-неймспейсе.

## Что поднимается

- `n8n` на `http://localhost:5678`
- `qdrant` на `http://localhost:6333`

Compose project name: `bot_showcase` (изолирован от других Docker-проектов).

## Подготовка

1. Убедись, что Docker Desktop запущен.
2. Проверь наличие `google-creds.json` в корне `Bot`.
3. Проверь `.env` (пример в `.env.example`).

## Быстрый запуск

Из папки `Bot\scripts`:

```powershell
.\up.ps1
```

## Проверка здоровья сервисов

```powershell
.\health.ps1
```

Ожидается:
- `n8n: OK (200)`
- `qdrant: OK (200)`

## Полезные команды

```powershell
.\status.ps1
.\logs.ps1
.\logs.ps1 n8n
.\logs.ps1 qdrant
.\down.ps1
```

## Demo workflow (для витрины)

- Workflow JSON: `workflows/bot_memory_demo.workflow.json`
- LLM workflow JSON: `workflows/assistant_chat_llm.workflow.json`
- Пример запроса: `samples/webhook_request.json`
- Пошаговая проверка: `DEMO_CHECKLIST.md`

### Assistant Chat (витринный сценарий)

Файл: `workflows/assistant_chat_llm.workflow.json`

| Что видит клиент (HTTP) | Что происходит внутри |
|-------------------------|------------------------|
| `POST http://localhost:5678/webhook/assistant-chat-v1` с JSON-телом | Workflow стартует; ответ приходит **сразу** в режиме асинхронного вебхука (тело вида «workflow started» — штатное поведение n8n для `responseMode: onReceived`). |
| Ответ модели в том же HTTP-запросе | В этой витринной сборке **не отдаётся** — чтобы обходить нестабильность синхронного `Respond to Webhook` на части установок. |

**Тело запроса:**

```json
{ "user_id": "u1", "message": "Привет" }
```

**Где смотреть результат от LLM:** в n8n открой **Executions** → последний запуск → выход ноды **Build Response** (`assistant_reply`, `input_message`, `model`). Так можно показать заказчику скрин «цепочка отработала».

**Переменные в `.env` (и в Environment n8n для контейнера):**

- `OPENAI_API_KEY`
- `OPENAI_BASE_URL` (например `https://api.openai.com/v1` или ваш совместимый шлюз)
- `OPENAI_MODEL` (например `gpt-4o-mini`)

Шаблон текста для карточки Kwork: `KWORK_OFFERING.md`. Пошаговая проверка: `DEMO_CHECKLIST.md`.

## Безопасность

- В `.gitignore` уже добавлены: `.env`, `google-creds.json`.
- Не публикуй `google-creds.json` и `.env` в репозитории/архивах.
