# RAG and vector databases

RAG (retrieval-augmented generation): fetch relevant facts from your own data at question time,
put them in the prompt, and let the LLM answer from them.

## Ingestion (once, and whenever documents change)
1. Load: PDF, Drive, website, DB rows
2. Chunk: about 300-800 tokens, 10-20% overlap
3. Embed: embedding model turns each chunk into a vector
4. Store: vector + original text + metadata in a vector DB

## Query (every question)
1. Embed the question with the same embedding model
2. Vector DB returns the top 3-5 nearest chunks
3. Prompt: "Answer using ONLY this context", then the chunks and the question
4. LLM answers, ideally with sources

## Embeddings
Text becomes a point in space where similar meaning means nearby points.
"refund policy" and "how do I return an item" land close together without sharing words.

## Vector DB
Stores vectors and finds nearest neighbors fast using ANN indexes (HNSW, IVFFlat).
Metric: cosine similarity (most common), dot product, L2. Supports metadata filters
(for example only `customer_id = 5`).

| DB | Good for |
|----|----------|
| pgvector / Supabase | Already know Postgres, one DB for everything |
| Pinecone | Managed, zero ops |
| Qdrant | Open source, self-host with Docker |
| Chroma / FAISS | Local prototypes |

## Where RAG fails
- Bad chunking (biggest cause of bad answers)
- Wrong embedding model for the language (test multilingual models for Bangla)
- top-k too low or too high
- No "I don't know" rule in the prompt
- Stale data (no re-ingestion)

## Upgrades
Hybrid search (vector + keyword), reranking, metadata filters, query rewriting, citations.
