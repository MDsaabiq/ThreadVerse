# Threadverse Backend

Node.js + Express + MongoDB API for Threadverse. Written in TypeScript.

## Quick start
1. Install Node.js 18+.
2. From repo root: `cd backend && npm install`.
3. Copy env: `cp .env.example .env` and adjust `MONGODB_URI`.
4. Run dev server: `npm run dev` (defaults to http://localhost:4000).
5. Health check: `GET /api/v1/healthz`.

## Scripts
- `npm run dev` – start with ts-node.
- `npm run build` – compile to `dist/`.
- `npm start` – run compiled build.
- `npm test` – run Jest tests.
- `npm run lint` – eslint.
- `npm run format` – prettier check.

## Notes
- Keep API base URL configurable on the Flutter side (e.g., `API_BASE_URL`).
- Allow your Flutter web origin in Express CORS if running locally (e.g., http://localhost:8080).
