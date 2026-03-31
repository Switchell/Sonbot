# Roadmap: SonBot → продукт для фриланса

## Текущая проблема

Сейчас бот технически рабочий; продуктовая полировка продолжается:
- есть приём webhook и запись памяти в Qdrant (`bot_memory_demo`);
- есть витринный workflow **Assistant Chat**: `POST /webhook/assistant-chat-v1` → Qdrant search → LLM → upsert → **JSON в ответе вебхука** (см. README);
- упаковка для Kwork: `KWORK_OFFERING.md`, чеклист в `DEMO_CHECKLIST.md`.

## Цель

Сделать витринный бот, который:
1. принимает сообщение,
2. формирует AI-ответ,
3. сохраняет контекст,
4. возвращает понятный JSON-результат,
5. легко разворачивается у клиента.

## План реализации

### Этап 1 (сейчас)
- [x] Workflow `assistant-chat-v1` (Webhook + LLM), файл `assistant_chat_llm.workflow.json`
- [x] OpenAI-compatible API через `.env`
- [x] e2e: вебхук + проверка **Executions**; память — отдельным workflow `bot_memory_demo`

### Этап 2
- [x] Memory retrieval: Qdrant `points/search` по тому же латентному «вектору», что и в `bot_memory_demo`, фильтр `user_id`
- [x] Промпт с блоком памяти в system message
- [x] Поля ответа: `used_memory_count`, `model`, `latency_ms`, `memory_upsert_ok`

### Этап 3
- [ ] Telegram trigger + reply
- [ ] Базовая защита от спама/пустых сообщений
- [ ] Клиентский README и "what you get"

## Критерий готовности

**Текущая витрина:** один ассистентский workflow с LLM + Qdrant в одной цепочке; синхронный JSON из **Respond to Webhook**; отдельный `bot-memory-demo` по желанию для чистой демонстрации только памяти.

**Дальше (этап 3 и идеи):**
- Telegram и другие каналы;
- настоящие эмбеддинги вместо демо-вектора из длины строки (если заказчик нужен семантический поиск);
- rate-limit / антиспам на входе вебхука.
