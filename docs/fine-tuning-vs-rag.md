# Fine-tuning vs RAG

Fine-tuning trains an existing model further on your examples, so its **behavior** changes
(weights change, not the prompt). RAG gives the model **knowledge** at question time.

| | RAG | Fine-tuning |
|---|---|---|
| Goal | Give the model knowledge | Change behavior, style, format |
| Data updates | Instant (re-ingest) | Retrain |
| Cost | Low | Higher |
| Hallucination control | Good, with sources | Weaker |

Good for fine-tuning: brand voice, strict output format, narrow classification or extraction.
Bad for: adding facts, data that changes often.

Rule of thumb: prompt first, then RAG, fine-tune only if style or format is still off.
