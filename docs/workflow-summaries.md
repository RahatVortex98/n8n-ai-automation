# Workflow summaries

What each exported workflow does, in the order I built them.

## 01 Airtable form to record
**Flow:** Form submission, create Airtable record.
A public form ("Which room do you like?") collects a name and a room type (single, double bed, king size).
The answers are saved as a new record in an Airtable table.
**Learned:** form trigger, field mapping into Airtable, Airtable token credential.

## 02 Airtable search and export
**Flow:** Schedule (every minute), search Airtable, convert to file, write to disk.
Reads the `Room` field from Airtable records, turns it into a text file and writes it to a local folder.
**Learned:** schedule trigger, search operation, binary files and the Read/Write Files node.

## 03 Google Sheets spreadsheet
**Flow:** Manual run, create a spreadsheet.
Creates a new Google spreadsheet from n8n.
**Learned:** Google OAuth credentials, Google Sheets node basics.

## 04 Order notification email
**Flow:** Airtable trigger, Gemini writes the email, Code node parses it, Gmail sends it.
Checks Airtable every minute for new orders. Gemini turns the order details into a clear summary email
signed "Customer Success Team" and returns a subject and body. A Code node extracts `email_subject` and
`email_content` from the model output (with a fallback parser), and Gmail sends it to the team.
An OpenAI node is also on the canvas but not connected, since I used the free Gemini API.
**Learned:** polling trigger, prompting for structured output, JavaScript Code node, Gmail node.

## 05 Sentiment analysis
**Flow:** Form, Gemini classifies, merge, log to Sheets and email.
A review form takes a name and a review. A Basic LLM Chain (Gemini) answers with one word:
Positive, Negative or Neutral. Merge combines the form data with the AI answer by position, then the result
is appended as a row in Google Sheets and sent as an HTML table by Gmail.
**Learned:** Basic LLM Chain, system prompt for one-word output, Merge node, branching one output to two nodes.

![Sentiment analysis workflow](../screenshots/05-sentiment-analysis.png)

## 06 Open-source LLM agent
**Flow:** Chat trigger, AI Agent, Ollama chat model.
A chat window backed by an AI Agent that runs a local open-source model through Ollama.
No API key or paid subscription needed.
**Learned:** AI Agent node, chat model sub-node, running models locally.

## 07 RAG ingestion
**Flow:** Drive trigger, download file, data loader, Gemini embeddings, Pinecone.
Watches a Google Drive folder for new files. A new PDF is downloaded, the Default Data Loader (PDF loader)
turns it into chunks, Gemini creates embeddings, and the Pinecone Vector Store node inserts them into the
`n8n-rag-v2` index (namespace `n8n-rag`). In my test run, one PDF produced 74 items (chunks).
**Learned:** RAG ingestion, embeddings, vector databases, matching index dimension to the embedding model
(see [troubleshooting](troubleshooting.md)).

![RAG ingestion workflow](../screenshots/07-rag-ingestion.png)

## 08 RAG chatbot
**Flow:** Chat trigger, AI Agent. The agent has a Gemini chat model, Simple Memory and one tool.
The tool, "Answer questions with a vector store", combines the Pinecone Vector Store
(index `n8n-rag-v2`, Gemini embeddings) with its own Gemini chat model.

How a question is answered:
1. The Chat trigger passes the message to the AI Agent.
2. The agent reads its prompt and the memory (recent messages) and decides whether it needs the documents.
3. It calls the Q&A tool, which embeds the question, finds the closest chunks in Pinecone, and a Gemini model writes an answer from them.
4. The agent replies, and Simple Memory saves the exchange.

In my test run the tool was called 3 times and the embeddings node produced 9216 values (3 searches at 3072 dimensions).

**Agent prompt as exported:** answer from the Q3 and Q4 reports only, concise, with numbers, and name the quarter each fact comes from.

**Stricter version I plan to use (cleaned up, with "always call the tool"):**
```
You are an AI assistant specialized in analyzing Tesla's quarterly financial reports.
Answer questions accurately and precisely using the vector database, which contains the uploaded reports.

ALWAYS call the vector store tool before answering. Only provide information you retrieve from the documents.
If the information is not in the documents or is unclear, say: "I don't have this information in the uploaded reports."
Never answer from your own knowledge.

Response format:
- Concise and to the point
- Specific numbers and facts when available
- Say which quarterly report each fact comes from
```

**Learned:** AI Agent vs fixed workflow, tools, memory vs vector store, chunks and embeddings, handling Gemini 503 errors
with Retry On Fail and a stable model (see [troubleshooting](troubleshooting.md)).

![RAG chatbot workflow](../screenshots/08-rag-chatbot.png)

**Settings in the export:** both Gemini chat models are `gemini-3.5-flash-lite`, Simple Memory keeps the last 10 messages,
and the Pinecone node uses index `n8n-rag-v2` with no namespace set.

**Check:** the ingestion workflow (07) writes to namespace `n8n-rag`, but the chatbot's Pinecone node has no namespace.
The namespace must be the same in both workflows, or the chatbot searches an empty namespace and finds nothing.

Workflow file: [`workflows/08-rag-chatbot.json`](../workflows/08-rag-chatbot.json)

## 09 Docs to Pinecone
**Flow:** Manual run, Google Docs "Get a document", Pinecone insert. Embeddings (Gemini) and the Default Data Loader plug into the Pinecone node.
Reads one Google Doc (a list of contacts and emails), turns it into chunks, embeds them and stores them in index `n8n-rag-v2`, namespace `n8n docs`.
**Learned:** the Pinecone node must be in **Insert Documents** mode for the Document connector to appear; the loader must be connected to it.

## 10 Mail agent
**Flow:** Chat trigger, AI Agent with Gemini, Simple Memory and two tools.
- **Pinecone Vector Store** in "retrieve as tool" mode (same index and namespace `n8n docs`) finds a person's email address.
- **Send mail** is a Call n8n Workflow tool that runs workflow 11.

The agent prompt says: search first, send only when exactly one address matches, ask when several match, and never guess an address.
**Learned:** an agent can use several tools, tool descriptions and exact tool names in the prompt matter, and Pinecone can be attached straight to the agent with no Q&A node.

## 11 Send mail sub-workflow
**Flow:** Executed by another workflow (inputs `to`, `subject`, `message`) then Gmail Send a message.
The workflow the mail agent calls as a tool to send an email. The Gmail fields map to `{{ $json.to }}`, `{{ $json.subject }}` and `{{ $json.message }}`.
**Learned:** a workflow used as an agent tool must be **published**, otherwise it fails with "Workflow is not active and cannot be executed". Its trigger must define the input fields, or the agent sends everything as one `input` blob. Field names are case-sensitive, so the agent prompt must use lowercase `to`, `subject`, `message`.

## 12 Email agent
**Flow:** Chat trigger, AI Agent with Gemini (`gemini-3.5-flash-lite`), Simple Memory and a **Gmail "Send a message" tool**.
The agent drafts and refines an email, confirms the details with the user, and sends only after approval. The Gmail tool's To, Subject and Message are filled by the model (`$fromAI`).
**Learned:** a built-in app tool (Gmail) is the simplest way to give an agent an action, with no sub-workflow to publish. The "never send without approval" rule in the system message is a basic human-in-the-loop guard. Free-tier Gemini Pro models have a quota of 0, so use a Flash model.

## 13 Daily email summary
![Daily email summary](../screenshots/13-daily-email-summary.png)

**Flow:** Schedule trigger (01:00, Asia/Dhaka) → Gmail Get many messages (`newer_than:1d`) → Aggregate into one item → Gemini (`gemini-3.5-flash-lite`) → Gmail Send a message.
Gemini ranks the day's emails and returns an HTML fragment (priority summary and action items). The Gmail node wraps it in a styled HTML template and sends it as a digest.
**Learned:** Aggregate turns many items into one so the model gets all emails in a single call, and asking for an HTML fragment only (no markdown fences) lets it drop straight into an email template. No agent or RAG is needed, since the steps are fixed.
**Tips:** use the Gmail filter `in:inbox newer_than:1d` so sent mail is excluded. The Subject field must be in Expression mode to show the date, and the footer time should match the trigger time.
