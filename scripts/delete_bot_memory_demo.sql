-- Удаляет workflow bot_memory_demo из SQLite БД n8n (volume sonbot_n8n_data).
-- Перед запуском: docker stop sonbot-n8n-1
-- Запуск:
--   docker run --rm -v sonbot_n8n_data:/data -v "<repo>/scripts/delete_bot_memory_demo.sql:/q.sql:ro" alpine:3.19 sh -c "apk add --no-cache sqlite >/dev/null && sqlite3 /data/database.sqlite < /q.sql"

PRAGMA foreign_keys = OFF;
BEGIN TRANSACTION;

DELETE FROM test_case_execution WHERE testRunId IN (SELECT id FROM test_run WHERE workflowId = 'bot_memory_demo');
DELETE FROM test_run WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_builder_session WHERE workflowId = 'bot_memory_demo';

DELETE FROM execution_annotation_tags WHERE annotationId IN (
  SELECT id FROM execution_annotations WHERE executionId IN (
    SELECT id FROM execution_entity WHERE workflowId = 'bot_memory_demo'
  )
);
DELETE FROM execution_annotations WHERE executionId IN (
  SELECT id FROM execution_entity WHERE workflowId = 'bot_memory_demo'
);

DELETE FROM execution_data WHERE executionId IN (
  SELECT id FROM execution_entity WHERE workflowId = 'bot_memory_demo'
);
DELETE FROM execution_metadata WHERE executionId IN (
  SELECT id FROM execution_entity WHERE workflowId = 'bot_memory_demo'
);
DELETE FROM execution_entity WHERE workflowId = 'bot_memory_demo';

DELETE FROM shared_workflow WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_statistics WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_history WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_dependency WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_publish_history WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflow_published_version WHERE workflowId = 'bot_memory_demo';
DELETE FROM workflows_tags WHERE workflowId = 'bot_memory_demo';
DELETE FROM webhook_entity WHERE workflowId = 'bot_memory_demo';

DELETE FROM workflow_entity WHERE id = 'bot_memory_demo';

COMMIT;

SELECT 'workflows after delete:' AS info;
SELECT id, name FROM workflow_entity;
