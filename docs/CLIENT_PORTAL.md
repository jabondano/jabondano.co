# Client Portal Documentation

> Secure document sharing system for jabondano.co

## Quick Reference

| Task | Command/Location |
|------|------------------|
| Portal URL | `https://jabondano.co/portal.html` |
| Supabase Dashboard | `https://supabase.com/dashboard/project/acvgtacybmjdjpupttfa` |
| Add new client | [See: Adding Clients](#adding-a-new-client) |
| Share document | [See: Adding Documents](#adding-documents) |
| Create project | Just use a new `project_name` when adding documents |

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   jabondano.co                    Supabase                       │
│   ┌──────────────┐               ┌──────────────────────┐       │
│   │ index.html   │               │ Authentication       │       │
│   │ (main site)  │               │ - Magic link login   │       │
│   │              │               │ - User management    │       │
│   │ [Portal Btn] │───────────────│                      │       │
│   └──────────────┘               │ Database (PostgreSQL)│       │
│          │                       │ - clients            │       │
│          ▼                       │ - documents          │       │
│   ┌──────────────┐               │ - client_uploads     │       │
│   │ portal.html  │◄─────────────►│ - comments           │       │
│   │ (client app) │               │                      │       │
│   │              │               │ Storage              │       │
│   │ - Projects   │               │ - documents bucket   │       │
│   │ - Documents  │               │ - client-uploads     │       │
│   │ - Uploads    │               └──────────────────────┘       │
│   │ - Comments   │                                               │
│   └──────────────┘                                               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Features

- **Magic Link Auth**: Clients log in via email link (no passwords)
- **Project Organization**: Documents grouped by project folders
- **Per-Client Isolation**: Row Level Security ensures clients only see their data
- **Comments**: Collaboration on documents
- **File Uploads**: Clients can upload files back to you
- **Markdown Rendering**: Research documents render beautifully

---

## Database Schema

### Tables

#### `clients`
Links Supabase auth users to client profiles.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `user_id` | UUID | Links to `auth.users.id` |
| `name` | TEXT | Client's display name |
| `email` | TEXT | Client's email (unique) |
| `company` | TEXT | Optional company name |
| `created_at` | TIMESTAMP | Auto-set |
| `updated_at` | TIMESTAMP | Auto-updated |

#### `documents`
Research documents you share with clients.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `client_id` | UUID | Links to `clients.id` |
| `title` | TEXT | Document title |
| `description` | TEXT | Brief summary |
| `project_name` | TEXT | Groups docs into projects |
| `content_md` | TEXT | Markdown content |
| `file_url` | TEXT | URL if file-based |
| `file_type` | TEXT | 'markdown', 'pdf', etc. |
| `is_published` | BOOLEAN | Show to client (default: true) |
| `created_at` | TIMESTAMP | Auto-set |
| `updated_at` | TIMESTAMP | Auto-updated |

#### `client_uploads`
Files uploaded by clients.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `client_id` | UUID | Links to `clients.id` |
| `document_id` | UUID | Optional: attach to document |
| `filename` | TEXT | Original filename |
| `file_url` | TEXT | Storage URL |
| `file_size` | INTEGER | Size in bytes |
| `file_type` | TEXT | MIME type |
| `notes` | TEXT | Optional notes |
| `uploaded_at` | TIMESTAMP | Auto-set |

#### `comments`
Comments on documents.

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `document_id` | UUID | Links to `documents.id` |
| `user_id` | UUID | Links to `auth.users.id` |
| `content` | TEXT | Comment text |
| `is_owner` | BOOLEAN | True = shows as "Joaquin" |
| `created_at` | TIMESTAMP | Auto-set |
| `updated_at` | TIMESTAMP | Auto-updated |

---

## Common Operations

### Adding a New Client

**Step 1**: Client visits portal and enters their email (creates auth.users record)

**Step 2**: Find their user ID in Supabase:
```sql
SELECT id, email FROM auth.users WHERE email = 'client@example.com';
```

**Step 3**: Create client profile:
```sql
INSERT INTO public.clients (user_id, name, email, company)
VALUES (
    'user-id-from-step-2',
    'Client Name',
    'client@example.com',
    'Company Name'
);
```

### Adding Documents

**Single document**:
```sql
INSERT INTO public.documents (client_id, project_name, title, description, content_md)
VALUES (
    'client-id-here',
    'Project Name',
    'Document Title',
    'Brief description',
    '# Markdown Content

## Section 1
Your content here...

## Section 2
More content...'
);
```

**Multiple documents for same project**:
```sql
INSERT INTO public.documents (client_id, project_name, title, description, content_md) VALUES
('client-id', 'Q1 Research', 'Market Analysis', 'Market overview', '# Market Analysis...'),
('client-id', 'Q1 Research', 'Competitor Report', 'Competitor deep dive', '# Competitors...'),
('client-id', 'Q1 Research', 'Recommendations', 'Action items', '# Recommendations...');
```

### Creating a New Project

Projects are created automatically when you use a new `project_name`:
```sql
-- This creates a new "AI Strategy" project
INSERT INTO public.documents (client_id, project_name, title, description, content_md)
VALUES ('client-id', 'AI Strategy', 'Implementation Plan', '...', '...');
```

### Replying to Comments (as Owner)

```sql
INSERT INTO public.comments (document_id, user_id, content, is_owner)
VALUES (
    'document-id',
    'your-user-id',
    'Thanks for the question! Here is my response...',
    true  -- Shows "Joaquin" with Author badge
);
```

### Hiding a Document

```sql
UPDATE public.documents
SET is_published = false
WHERE id = 'document-id';
```

### Getting Client's Documents

```sql
SELECT d.*, c.name as client_name
FROM public.documents d
JOIN public.clients c ON d.client_id = c.id
WHERE c.email = 'client@example.com'
ORDER BY d.project_name, d.created_at DESC;
```

---

## File Structure

```
jabondano.co/
├── index.html              # Main website (has "Client Portal" button)
├── portal.html             # Client portal application
├── supabase-schema.sql     # Database schema (for reference/new setups)
├── PORTAL_SETUP.md         # Initial setup instructions
├── docs/
│   └── CLIENT_PORTAL.md    # This documentation
└── assets/
    └── ...                 # Images, favicon, etc.
```

---

## Security Model

### Row Level Security (RLS)

All tables have RLS enabled. Policies ensure:

| Table | Client Can |
|-------|------------|
| `clients` | View/update only their own profile |
| `documents` | View only documents where `client_id` matches theirs |
| `client_uploads` | View/insert/delete only their own uploads |
| `comments` | View comments on their docs, add/edit/delete own comments |

### Keys

| Key | Location | Purpose |
|-----|----------|---------|
| `anon` (publishable) | `portal.html` | Client-side auth, protected by RLS |
| `service_role` | **NEVER in code** | Admin operations only |

The `anon` key is safe to expose because RLS restricts all operations.

---

## Troubleshooting

### "No projects yet" after login
- **Cause**: No `clients` record linked to user
- **Fix**: Create client profile (see Adding a New Client)

### Magic link not received
- Check spam folder
- Verify Auth URL Configuration in Supabase:
  - Site URL: `https://jabondano.co`
  - Redirect URLs: `https://jabondano.co/portal.html`

### Document not showing for client
- Verify `client_id` matches the client's record
- Check `is_published = true`
- Confirm client profile exists with correct `user_id`

### Upload failing
- Check storage bucket policies
- Verify client has valid `client_id`
- File size limit is 50MB

---

## Future Enhancements (Ideas)

- [ ] Email notifications when new documents added
- [ ] Document versioning
- [ ] Read receipts
- [ ] PDF generation from markdown
- [ ] Custom branding per client
- [ ] Deadline/due date tracking
- [ ] Client notes/todo lists

---

## Supabase Dashboard Quick Links

- **Project**: https://supabase.com/dashboard/project/acvgtacybmjdjpupttfa
- **Table Editor**: .../project/acvgtacybmjdjpupttfa/editor
- **SQL Editor**: .../project/acvgtacybmjdjpupttfa/sql
- **Authentication**: .../project/acvgtacybmjdjpupttfa/auth/users
- **Storage**: .../project/acvgtacybmjdjpupttfa/storage/buckets

---

## Example: Full Client Setup

```sql
-- 1. Client signs up at portal (wait for them to enter email)

-- 2. Find their user ID
SELECT id, email FROM auth.users ORDER BY created_at DESC LIMIT 5;

-- 3. Create client profile
INSERT INTO public.clients (user_id, name, email, company)
VALUES (
    '12345678-abcd-1234-abcd-1234567890ab',
    'Jane Smith',
    'jane@acmecorp.com',
    'Acme Corporation'
) RETURNING id;

-- 4. Create a project with documents (use returned client id)
INSERT INTO public.documents (client_id, project_name, title, description, content_md) VALUES
(
    'returned-client-id',
    'Digital Transformation',
    'Assessment Report',
    'Current state analysis and recommendations',
    '# Digital Transformation Assessment

## Executive Summary
Based on our analysis...

## Current State
- Finding 1
- Finding 2

## Recommendations
1. Priority action
2. Secondary action

## Next Steps
Schedule follow-up call to discuss.'
),
(
    'returned-client-id',
    'Digital Transformation',
    'Implementation Roadmap',
    'Phased approach to transformation',
    '# Implementation Roadmap

## Phase 1: Foundation (Q1)
- Infrastructure updates
- Team training

## Phase 2: Pilot (Q2)
- Select use cases
- Build MVPs

## Phase 3: Scale (Q3-Q4)
- Roll out successful pilots
- Measure and optimize'
);

-- 5. Done! Client can now log in and see their project
```
