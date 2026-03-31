# Roadmap: Bot -> Freelance Product

## Текущая проблема

Сейчас бот технически рабочий; продуктовая полировка продолжается:
- есть приём webhook и запись памяти в Qdrant (`bot_memory_demo`);
- есть витринный workflow **Assistant Chat**: `POST /webhook/assistant-chat-v1` → LLM → ответ в ноде **Build Response** (в HTTP ответе вебхука — служебное тело из‑за `onReceived`, см. README);
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
- [ ] Добавить memory retrieval (поиск похожего контекста)
- [ ] Собрать prompt с историей
- [ ] Вернуть отладочные поля в ответе (used_memory_count, model, latency)

### Этап 3
- [ ] Telegram trigger + reply
- [ ] Базовая защита от спама/пустых сообщений
- [ ] Клиентский README и "what you get"

## Критерий готовности

**Минимальная витрина (уже есть):** вебхук стартует workflow; AI-текст смотрится в Executions → **Build Response**; память — через `bot-memory-demo`; запуск по README/DEMO_CHECKLIST.

**Следующий критерий «как у продукта в одном запросе»:**
- `POST /webhook/assistant-chat-v1` (или новый путь) стабильно отдаёт JSON с полем ответа модели в том же HTTP-ответе;
- опционально объединить LLM + Qdrant в одной цепочке под задачу заказчика.
