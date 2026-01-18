# Client Portal Setup Guide

This guide walks you through setting up the Supabase-powered client portal for jabondano.co.

## Overview

The portal allows you to:
- Share research documents (Markdown, PDFs) with specific clients
- Clients can view documents, upload files, and leave comments
- Each client only sees their own documents (row-level security)
- Magic link authentication (no passwords)

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up (free)
2. Click "New Project"
3. Choose a name (e.g., `jabondano-portal`)
4. Set a database password (save this!)
5. Choose a region close to you
6. Click "Create new project"

## Step 2: Run Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of `supabase-schema.sql` and paste it
4. Click "Run" (or Ctrl+Enter)
5. You should see "Success. No rows returned" for each statement

## Step 3: Configure Authentication

1. Go to **Authentication** > **Providers**
2. Ensure "Email" is enabled
3. Go to **Authentication** > **URL Configuration**
4. Set **Site URL** to: `https://jabondano.co`
5. Add to **Redirect URLs**: `https://jabondano.co/portal.html`

## Step 4: Get Your API Keys

1. Go to **Settings** > **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxx.supabase.co`)
   - **anon public** key (safe to use in browser)
   - **service_role** key (KEEP SECRET - for your admin scripts only)

## Step 5: Update Portal Configuration

Edit `portal.html` and replace the placeholder values (around line 580):

```javascript
const SUPABASE_URL = 'https://your-project.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';
```

## Step 6: Deploy

Just push to GitHub - GitHub Pages will deploy automatically:

```bash
git add .
git commit -m "Add client portal with Supabase integration"
git push
```

Visit: `https://jabondano.co/portal.html`

---

## Managing Clients & Documents

### Adding a New Client

After a client signs up (receives magic link and clicks it), you need to link them to a client profile.

**Option A: Via Supabase Dashboard**

1. Go to **Authentication** > **Users** to find their `user_id`
2. Go to **Table Editor** > **clients**
3. Insert a new row:
   - `user_id`: (from step 1)
   - `name`: Client's name
   - `email`: Their email
   - `company`: Optional

**Option B: Via SQL (faster)**

```sql
-- Find the user ID first
SELECT id, email FROM auth.users WHERE email = 'client@example.com';

-- Then create client profile
INSERT INTO public.clients (user_id, name, email, company)
VALUES (
    'uuid-from-above',
    'Client Name',
    'client@example.com',
    'Company Name'
);
```

### Uploading Documents (Your Workflow)

**Via Supabase Dashboard:**

1. Go to **Table Editor** > **documents**
2. Insert new row:
   - `client_id`: The client's UUID from the clients table
   - `title`: Document title
   - `description`: Brief summary
   - `content_md`: Paste your markdown content here
   - `file_type`: 'markdown' (or 'pdf' if uploading file)
   - `is_published`: true

**Via SQL (for Claude Code automation):**

```sql
-- Get client ID
SELECT id FROM public.clients WHERE email = 'client@example.com';

-- Insert document
INSERT INTO public.documents (client_id, title, description, content_md, file_type)
VALUES (
    'client-uuid-here',
    'Q1 2024 Research Report',
    'Analysis of market trends and recommendations',
    '# Research Report

## Executive Summary

Key findings...

## Recommendations

1. First recommendation
2. Second recommendation
',
    'markdown'
);
```

### Uploading Files (PDFs, etc.)

1. Go to **Storage** > **documents** bucket
2. Create a folder with the client's UUID
3. Upload the file there
4. Copy the file URL
5. Create a document record with `file_url` instead of `content_md`

---

## Claude Code Integration

To upload documents directly from Claude Code, you can use the Supabase CLI or REST API.

### Using REST API

```bash
# Set your service role key (keeps admin access)
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_KEY="your-service-role-key"

# Upload a document
curl -X POST "$SUPABASE_URL/rest/v1/documents" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "client-uuid",
    "title": "New Research Document",
    "description": "Description here",
    "content_md": "# Markdown content here...",
    "file_type": "markdown"
  }'
```

### Helper Script

Create `upload-doc.sh` for easy uploads:

```bash
#!/bin/bash
# Usage: ./upload-doc.sh client@email.com "Title" "Description" content.md

CLIENT_EMAIL=$1
TITLE=$2
DESCRIPTION=$3
CONTENT_FILE=$4

# Get client ID
CLIENT_ID=$(curl -s "$SUPABASE_URL/rest/v1/clients?email=eq.$CLIENT_EMAIL&select=id" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" | jq -r '.[0].id')

# Read markdown content
CONTENT=$(cat "$CONTENT_FILE" | jq -Rs .)

# Upload document
curl -X POST "$SUPABASE_URL/rest/v1/documents" \
  -H "apikey: $SUPABASE_KEY" \
  -H "Authorization: Bearer $SUPABASE_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"client_id\": \"$CLIENT_ID\",
    \"title\": \"$TITLE\",
    \"description\": \"$DESCRIPTION\",
    \"content_md\": $CONTENT,
    \"file_type\": \"markdown\"
  }"

echo "Document uploaded!"
```

---

## Adding Comments as Owner

To reply to client comments (showing as "Joaquin" with Author badge):

```sql
INSERT INTO public.comments (document_id, user_id, content, is_owner)
VALUES (
    'document-uuid',
    'your-user-uuid',  -- Your auth user ID
    'Thanks for the question! Here is my response...',
    true  -- This shows the "Author" badge
);
```

---

## Security Notes

1. **Never expose** the `service_role` key in client-side code
2. The `anon` key is safe for the browser (RLS protects data)
3. All client data is isolated via Row Level Security
4. Magic links expire after 1 hour by default
5. Storage files are private by default (require auth)

---

## Troubleshooting

### "No documents shared yet"
- Check that the client profile exists and is linked to the auth user
- Verify documents have `is_published = true`
- Check that `client_id` matches the client's record

### Login link not working
- Verify redirect URL is in Supabase Auth settings
- Check Site URL is set correctly
- Links expire after 1 hour

### Uploads failing
- Check storage bucket exists and policies are applied
- Verify client has a valid `client_id` folder in storage
- File size limit is 50MB by default

---

## Costs

**Supabase Free Tier Includes:**
- 500MB database
- 1GB storage
- 50,000 monthly active users
- Unlimited API requests

**You'll likely never exceed free tier** with 1-5 clients.

If you scale up: Pro plan is $25/month.
