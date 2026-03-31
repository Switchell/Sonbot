# Bot Demo Checklist

## 1) Поднять сервисы

```powershell
cd "C:\Users\Son\Desktop\Кодинг проекты\Bot\scripts"
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

## 5) Assistant Chat (LLM)

1. Импортировать `workflows/assistant_chat_llm.workflow.json` (или обновить существующий workflow из файла).
2. Убедиться, что в `.env` заданы `OPENAI_API_KEY`, `OPENAI_BASE_URL`, `OPENAI_MODEL`, контейнер n8n перезапущен после изменения env (`.\down.ps1` / `.\up.ps1` или `docker compose up -d` из корня `Bot`).
3. Активировать workflow в UI n8n.

**Тест вебхука** (путь: `assistant-chat-v1`):

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://localhost:5678/webhook/assistant-chat-v1" `
  -ContentType "application/json" `
  -Body '{"user_id":"u-demo","message":"Скажи одним предложением, что умеет n8n."}'
```

**Ожидаемое сразу в ответе:** служебный ответ о том, что workflow запущен (не текст модели).

**Ожидаемое в n8n:** `Executions` → последний run → **Build Response** → в JSON поле `assistant_reply` с ответом модели, `input_message` совпадает с отправленным `message`.

## 6) Что показывать заказчику на витрине

- Скрин: активный workflow «Assistant Chat» в списке n8n.
- Скрин или короткое видео: **Executions** с зелёным статусом и раскрытым выходом **Build Response**.
- При необходимости — отдельно демо **bot-memory-demo** и список коллекций Qdrant (`bot_memory`).
