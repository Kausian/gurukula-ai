# Gurukula AI — Zero-cost plan

Gurukula is built to run at **no cost**: no backend, no paid APIs, no billing
account. This document lists exactly what is used and what is deliberately
avoided.

## What is used (all free)

| Need | Choice | Cost |
|---|---|---|
| App framework | Flutter + Dart | Free, open source |
| Native integration | Kotlin + Flutter MethodChannel | Free |
| State management | Riverpod | Free |
| Navigation | go_router | Free |
| Local database | Hive CE | Free, on-device |
| Identity | Firebase Authentication (Google) | Free (Spark plan) |
| On-device AI | ML Kit GenAI / Gemini Nano via AICore | Free, on-device |
| AI fallback | MockAiService (local heuristics) | Free |
| Fonts | Plus Jakarta Sans, bundled locally | Free |
| Source / hosting | GitHub (+ GitHub Pages later) | Free |

## What is deliberately avoided

- **No Firestore, Cloud Storage, or Cloud Functions** — study data never goes
  to the cloud, so there is nothing to bill.
- **No Gemini Cloud API, no OpenAI API** — all AI is on-device or mock.
- **No paid OCR, no vector database, no managed backend** (no AWS/GCP server,
  no Supabase).
- **No analytics** that would require a paid tier.

## Why it stays free

- **Firebase Authentication** is free on the Spark plan and needs no card. It is
  the *only* cloud service, and it is used for identity only.
- **All study data lives in Hive on the device**, so storage and compute cost
  nothing.
- **AI runs on the device** (Gemini Nano where available) or falls back to a
  local mock. No per-request API charges.
- There is **no server to host**, so there are no hosting costs.

## Internet usage

- **Once**, for Google Sign-In (and the first Gemini Nano model download on a
  supported device).
- After that, the core study features work **fully offline**.
