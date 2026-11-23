# Workflows

Export from n8n: open the workflow, **⋯ menu, Download**.

Naming: `NN-short-name.json`, for example `02-rag-ingestion.json`.

Before committing, scan for secrets:

```powershell
Select-String -Path workflows\*.json -Pattern "pcsk_|sk-|AIza|Bearer|api[_-]?key"
```

Remove any real key found in HTTP Request or Code nodes.
