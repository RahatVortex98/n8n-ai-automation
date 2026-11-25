# Lessons learned

## Which pattern to use
- **Fixed workflow** when the steps are known (summary email, sentiment analysis). Cheaper, predictable, easy to debug.
- **RAG** when the answer lives in your own documents.
- **Agent** only when the steps cannot be predicted. Many "agents" are really fixed sequences.
- AI automation also needs: webhooks and HTTP/API calls, structured (JSON) output, error handling and retries,
  human approval before risky actions, and cost control. It is not only RAG and agents.

## Agents
- Put instructions in **System Message**, and set the prompt source to the chat trigger.
- Tool names and descriptions matter. Name them in the system message.
- Use lowercase field names consistently between prompt, tool and sub-workflow.
- A built-in app tool (for example the Gmail tool, workflow 12) is simpler than a sub-workflow tool (workflows 10 and 11).
- A sub-workflow used as a tool must be published and must define its input fields.
- Add "never send without approval" to the prompt for any action that cannot be undone.

## Gemini
- Use Flash models on the free tier. Pro models have a quota of 0.
- Turn on Retry On Fail for 503 overloads. Change the model in every Gemini node, not just one.

## Gmail
- Search filter for a daily digest: `in:inbox newer_than:1d`. Plain `newer_than:1d` also includes sent mail.
- Fields containing `{{ }}` must be in Expression mode.

## Security
- Never paste API keys into chats or commit them. Replace credential IDs and personal emails in exported JSON.
