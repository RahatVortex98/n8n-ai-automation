# Usage (PowerShell):
#   $env:PINECONE_API_KEY = "your-key"     # set in your session only, do not commit
#   .\scripts\create-pinecone-index.ps1 -Name n8n-rag-v2 -Dimension 3072
param(
  [string]$Name = "n8n-rag-v2",
  [int]$Dimension = 3072,
  [string]$Metric = "cosine",
  [string]$Cloud = "aws",
  [string]$Region = "us-east-1"
)

if (-not $env:PINECONE_API_KEY) { throw "Set `$env:PINECONE_API_KEY first." }

$body = @{
  name = $Name
  vector_type = "dense"
  dimension = $Dimension
  metric = $Metric
  spec = @{ serverless = @{ cloud = $Cloud; region = $Region } }
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Method Post -Uri "https://api.pinecone.io/indexes" `
  -Headers @{ "Api-Key" = $env:PINECONE_API_KEY; "X-Pinecone-Api-Version" = "2025-10"; "Accept" = "application/json" } `
  -ContentType "application/json" -Body $body
