# Bookstore UI

React + TypeScript frontend for the Bookstore API.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 🔧 Configuration

Create `.env.production` file:

```
VITE_API_URL=https://api.zhong.nz
```

For local development, `.env.development` is already configured to use `http://localhost:8080`.

## 📦 Features

- ✅ Browse books
- ✅ View book details
- ✅ Browse authors
- ✅ View author details and their books
- ✅ Responsive design
- ✅ TypeScript for type safety
- ✅ React Router for navigation

## 🌐 Deployment to Vercel

### Required Environment Variables

**IMPORTANT**: The following environment variables MUST be configured in Vercel for the application to work:

| Variable | Value | Environment |
|----------|-------|-------------|
| `VITE_API_URL` | `https://api.zhong.nz` | Production |

### Setting Environment Variables

**Option 1: Using Vercel CLI**
```bash
cd bookstore-ui
npx vercel env add VITE_API_URL production
# When prompted, enter: https://api.zhong.nz
```

**Option 2: Using Vercel Dashboard**
1. Go to your project in Vercel Dashboard
2. Navigate to **Settings** → **Environment Variables**
3. Add new variable:
   - **Name**: `VITE_API_URL`
   - **Value**: `https://api.zhong.nz`
   - **Environment**: Production

### Deploying

```bash
# Install Vercel CLI (if not already installed)
npm install -g vercel

# Deploy to production
vercel --prod
```

**Note**: Environment variables are NOT stored in Git (per Vercel's design). They must be configured in Vercel's UI or CLI.

## 📁 Project Structure

```
src/
├── components/
│   ├── BookList.tsx        # Books listing page
│   ├── BookDetail.tsx      # Book detail page
│   ├── AuthorList.tsx      # Authors listing page
│   └── AuthorDetail.tsx    # Author detail page
├── services/
│   └── api.ts              # API client
├── App.tsx                 # Main app component
├── main.tsx               # Entry point
├── App.css                # Styles
└── index.css              # Global styles
```

## 🔗 API Integration

The app connects to the Bookstore API at `https://api.zhong.nz` (production) or `http://localhost:8080` (development).

Endpoints used:
- `GET /api/books` - List all books
- `GET /api/books/{id}` - Get book details
- `GET /api/authors` - List all authors
- `GET /api/authors/{id}` - Get author details
- `GET /api/authors/{id}/books` - Get author's books
