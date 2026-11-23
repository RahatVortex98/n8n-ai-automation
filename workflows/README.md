# Workflows

Exported from n8n (workflow menu, Download) and cleaned before committing:
emails, Airtable/Drive/Sheet IDs and the n8n instance ID are replaced with `YOUR_...` placeholders,
and credentials are references only (no secrets).

To use one: n8n, Workflows, Import from file, then set your own credentials and replace the `YOUR_...` values.

Naming: `NN-short-name.json`.

Scan before committing a new export:

```powershell
Select-String -Path workflows\*.json -Pattern "pcsk_|sk-|AIza|Bearer|api[_-]?key|@gmail"
```
