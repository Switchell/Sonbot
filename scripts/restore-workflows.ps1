Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$WorkflowsDir = Join-Path $RepoRoot "workflows"

$n8nName = docker ps --filter "name=sonbot-n8n" --format "{{.Names}}" | Select-Object -First 1
if (-not $n8nName) {
  Write-Error "Container sonbot-n8n not found. Run .\up.ps1 first."
}

Write-Host "n8n container: $n8nName"
Write-Host "git pull..."
Push-Location $RepoRoot
try {
  git pull origin master
}
finally {
  Pop-Location
}

$files = @(
  "bot_memory_demo.workflow.json",
  "assistant_chat_llm.workflow.json"
)

foreach ($f in $files) {
  $src = Join-Path $WorkflowsDir $f
  if (-not (Test-Path -LiteralPath $src)) {
    Write-Error "Missing file: $src"
  }
  $dest = "/tmp/$f"
  Write-Host "docker cp -> $dest"
  docker cp -- $src "${n8nName}:$dest"
  Write-Host "n8n import $f"
  docker exec $n8nName n8n import:workflow --input=$dest
}

Write-Host "Activate workflows..."
docker exec $n8nName n8n update:workflow --id=bot_memory_demo --active=true
docker exec $n8nName n8n update:workflow --id=assistant_chat_llm --active=true
Write-Host "Restart n8n (register webhooks)..."
docker restart $n8nName
Write-Host "Done. Open http://localhost:5678/home/workflows and refresh."
