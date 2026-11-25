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

## 8. Agent says "I am ready. Please provide..." and ignores the question
The prompt was in the AI Agent's user-message field (`promptType: define`), so the agent never saw the chat text.
Set the prompt source to **Connected Chat Trigger Node** and put the instructions in
**Options → System Message**.

## 9. "Workflow is not active and cannot be executed" (Call n8n Workflow tool)
A workflow used as an agent tool must be **published**. Publish the sub-workflow, then reopen the tool in the
agent. The model may report this as "the mail service is inactive", so check the tool's **Output** in the chat Logs.

## 10. Sub-workflow tool gets one `input` blob, or "Required at to, subject, message"
- The sub-workflow trigger must use **Define using fields below** (here `to`, `subject`, `message`, all String),
  otherwise the agent sends everything as a single `input` field.
- Field names are case-sensitive. If the system prompt says "To, Subject, Message" the model sends capitals
  and the schema check fails. Use lowercase names in the prompt, the trigger and the tool.
- Click ✨ on each field in the tool node, and start a new chat session so old failed calls are not copied.

## 11. Gmail "Invalid email address ''" in the sub-workflow
`to` arrived empty. Either the sub-workflow was executed directly (no data is passed), or the tool is not
passing its fields (see 10). Test from the agent's chat, not from the sub-workflow.

## 12. Gemini 429 "limit: 0" on a Pro model
Pro models (for example `gemini-3.1-pro`) have a free-tier quota of **0**, so waiting does not help.
Switch every Gemini node to a Flash model (`gemini-3.6-flash`, `gemini-3.5-flash-lite`).

## 13. Expression not evaluated (shows `{{ ... }}` as text)
A field must be in **Expression** mode (its value starts with `=`). Plain text with `{{ }}` is sent literally.
Example: the subject of the daily email summary.
