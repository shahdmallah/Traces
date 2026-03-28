# Traces

> Preserve the memory of places. Discover the world through those who've been there.

Traces is a travel platform that connects organized trip experiences with a living archive of place memories — photos, stories, and routes left behind by every traveler.

---

## Project Structure

```
traces/
├── traces_app/        # Flutter frontend (web + mobile)
├── traces_api/        # Node.js + TypeScript backend
└── supabase/          # Database migrations, seeds, edge functions
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (web + iOS + Android) |
| Backend | Node.js, TypeScript, Express |
| Database | Supabase (PostgreSQL + Realtime + Storage) |
| Auth | Supabase Auth (email, Google, Apple) |
| State (Flutter) | Riverpod |
| Validation (API) | Zod |

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Node.js 20+
- Supabase CLI
- A Supabase project (free tier works)

### 1. Clone the repo
```bash
git clone https://github.com/your-username/traces.git
cd traces
```

### 2. Set up Supabase
```bash
cd supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

### 3. Set up the API
```bash
cd traces_api
cp .env.example .env
# Fill in your Supabase URL and keys in .env
npm install
npm run dev
```

### 4. Set up the Flutter app
```bash
cd traces_app
cp .env.example .env
# Fill in your Supabase URL and anon key
flutter pub get
flutter run
```

---

## Environment Variables

### traces_api/.env
```
PORT=3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_ANON_KEY=your-anon-key
JWT_SECRET=your-jwt-secret
STRIPE_SECRET_KEY=your-stripe-key
STORAGE_BUCKET_MEDIA=traces-media
STORAGE_BUCKET_DOCS=traces-documents
```

### traces_app/.env
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:3000
```

---

## Supabase Setup Checklist

- [ ] Run `supabase/migrations/v1_core_schema.sql`
- [ ] Run `supabase/migrations/v2_social_financial.sql`
- [ ] Enable Realtime on: `messages`, `notifications`, `trivia_results`
- [ ] Create storage bucket: `traces-media` (public)
- [ ] Create storage bucket: `traces-documents` (private)
- [ ] Enable pg_cron extension (for scheduled notifications)
- [ ] Enable postgis extension (for geo queries)

---

## License

MIT
