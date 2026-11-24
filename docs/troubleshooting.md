# Troubleshooting log

## 1. "models/text-embedding-004 is not supported" (Gemini embeddings node)
Google retired `embedding-001` and `text-embedding-004`. It is not a subscription issue.
Use `gemini-embedding-2` (or `gemini-embedding-001`) with a Google AI Studio API key.
Default output is 3072 dimensions; flexible 128 to 3072 (768, 1536, 3072 recommended).

## 2. "expected 768 dimensions, not 3072"
The vector index dimension and the embedding model output must match, and the **same**
embedding model must be used for ingestion and for the chatbot.

## 3. "gemini-embedding-2 is not available on the Starter plan" (Pinecone)
That is Pinecone's own integrated-embedding list. Not needed: n8n's Gemini node makes the
vectors, Pinecone only stores them. Create a plain dense index instead.

## 4. "This index has a document schema, so writes must go through the documents API"
n8n's Pinecone node writes through the older vectors API, which document-schema indexes
reject. Create a plain dense index through the control-plane API:
see [`scripts/create-pinecone-index.ps1`](../scripts/create-pinecone-index.ps1)
(uses `X-Pinecone-Api-Version: 2025-10`, dimension 3072, cosine).

## 5. Pinecone 401 "Invalid API key"
Placeholder left in the command, or key copied wrongly. Never paste a real key into chats,
issues or commits. If one leaks, delete it in the Pinecone console and create a new one.

## 6. Gemini 503 "model is currently experiencing high demand"
Google's servers are overloaded. It happens on preview and stable models alike. Turn on
**Retry On Fail** (5 tries, 5000 ms) on the AI Agent and every Gemini model node, switch to a less busy
stable model (for example a Flash-Lite model), or add a fallback model. Local Ollama is a good backup.

## 7. Gemini 404 "model is no longer available to new users"
Google limits the 2.5 models (such as `gemini-2.5-pro` and `gemini-2.5-flash`) to accounts that used them before.
Use a current model such as `gemini-3.8-flash` or `gemini-3.5-flash-lite`, and change **every** Gemini model node
(the agent's and the one inside the Q&A tool).
