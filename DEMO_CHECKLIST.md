# SonBot — демо-чеклист

## 1) Поднять сервисы

```powershell
cd "<путь-к-репозиторию-SonBot>\scripts"
.\up.ps1
.\health.ps1
```

## 2) Импортировать workflow в n8n

1. Открыть `http://localhost:5678`
2. `Workflows` -> `Import from file`
3. Выбрать `workflows/bot_memory_demo.workflow.json`
4. Сохранить и активировать workflow

## 3) Прогнать тест вебхука

У workflow путь: `bot-memory-demo`  
Тест-запрос:

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://localhost:5678/webhook/bot-memory-demo" `
  -ContentType "application/json" `
  -Body (Get-Content "..\samples\webhook_request.json" -Raw)
```

Ожидаемый ответ:
- `status: "ok"`
- `stored_point_id` заполнен
- `similar_found` > 0

## 4) Проверка Qdrant

```powershell
Invoke-RestMethod -Method Get -Uri "http://localhost:6333/collections"
```

В списке должна быть коллекция `bot_memory`.

## 5) Assistant Chat (LLM + Qdrant)

0. Коллекция `bot_memory` уже есть (после шага 4 или ручного создания в Qdrant).
1. Импортировать `workflows/assistant_chat_llm.workflow.json` (или обновить существующий workflow из файла).
2. Убедиться, что в `.env` заданы `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`, контейнер n8n перезапущен после изменения env (`.\down.ps1` / `.\up.ps1` или `docker compose up -d` из корня репозитория).
3. Активировать workflow в UI n8n.

**Тест вебхука** (путь: `assistant-chat-v1`):

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://localhost:5678/webhook/assistant-chat-v1" `
  -ContentType "application/json" `
  -Body '{"user_id":"u-demo","message":"Скажи одним предложением, что умеет n8n."}'
```

**Ожидаемое в ответе PowerShell (объект JSON):** `status`, `assistant_reply`, `model`, `used_memory_count`, `latency_ms`, `memory_upsert_ok`, `user_id`, `input_message`.

**Ожидаемое в n8n:** `Executions` → последний run → цепочка до **Build API Response** и **Respond to Webhook**; при сбое LLM или Qdrant смотри выходы нод с ошибкой (`continueOnFail` на части шагов).

## 6) Что показывать заказчику на витрине

- Скрин: активный workflow «SonBot — Assistant Chat» в списке n8n.
- Скрин **ответа** тестового `Invoke-RestMethod` / Postman с полем `assistant_reply` или короткое видео **Executions**.
- При необходимости — отдельно демо **bot-memory-demo** и список коллекций Qdrant (`bot_memory`).
