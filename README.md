# SonBot (n8n + Qdrant)

Локальный проект **SonBot** для запуска n8n и Qdrant в отдельном Docker Compose‑неймспейсе.

## Что поднимается

- `n8n` на `http://localhost:5678`
- `qdrant` на `http://localhost:6333`

Compose project name: `sonbot` (изолирован от других Docker-проектов).

Если раньше проект поднимался как `bot_showcase`, Docker создаст **новые** тома для `sonbot`; данные из старых томов не подтянутся автоматически. Либо переименуй проект обратно в compose, либо перенеси данные вручную при необходимости.

## Подготовка

1. Убедись, что Docker Desktop запущен.
2. Проверь наличие `google-creds.json` в корне репозитория SonBot.
3. Проверь `.env` (пример в `.env.example`).

## Быстрый запуск

Из папки `scripts` в корне репозитория:

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

Цепочка: **вебхук → нормализация → поиск в Qdrant (`bot_memory`) → LLM с контекстом из памяти → запись диалога в Qdrant → JSON-ответ** (режим `Respond to Webhook`, как в `bot_memory_demo`).

| Шаг | Назначение |
|-----|------------|
| Qdrant Search | Вектор как в демо памяти + фильтр по `user_id`; в системный промпт попадают прошлые реплики. |
| LLM | OpenAI-совместимый `/chat/completions`. |
| Upsert | В коллекцию пишется пара «сообщение пользователя» + `assistant_reply`. |

**Тело запроса:**

```json
{ "user_id": "u1", "message": "Привет" }
```

**Ответ в том же HTTP-запросе** (пример полей): `status`, `assistant_reply`, `model`, `used_memory_count`, `latency_ms`, `memory_upsert_ok`.

Перед первым запуском ассистента коллекция **`bot_memory`** должна существовать: один раз прогони `bot_memory_demo` или создай коллекцию вручную в Qdrant. Если поиск по коллекции недоступен, нода поиска помечена `continueOnFail` — ответ всё равно соберётся, но память будет пустой.

Отладка: **Executions** в n8n — цепочка нод от **Webhook Trigger** до **Build API Response**.

**Переменные в `.env` (и в Environment n8n для контейнера):**

- `OPENAI_API_KEY`
- `OPENAI_BASE_URL` (например `https://api.openai.com/v1` или ваш совместимый шлюз)
- `OPENAI_MODEL` (например `gpt-4o-mini`)

Шаблон текста для карточки Kwork: `KWORK_OFFERING.md`. Пошаговая проверка: `DEMO_CHECKLIST.md`.

## Безопасность

- В `.gitignore` уже добавлены: `.env`, `google-creds.json`.
- Не публикуй `google-creds.json` и `.env` в репозитории/архивах.
