# Client Portal Cheatsheet

> Quick reference for common operations

## URLs

| Resource | URL |
|----------|-----|
| Portal | https://jabondano.co/portal.html |
| Supabase | https://supabase.com/dashboard/project/acvgtacybmjdjpupttfa |

---

## Add New Client

```sql
-- 1. Get user ID (after they've logged in once)
SELECT id, email FROM auth.users WHERE email = 'CLIENT_EMAIL';

-- 2. Create client
INSERT INTO public.clients (user_id, name, email, company)
VALUES ('USER_ID', 'NAME', 'EMAIL', 'COMPANY');
```

---

## Add Document to Client

```sql
-- Get client ID first
SELECT id FROM public.clients WHERE email = 'CLIENT_EMAIL';

-- Add document
INSERT INTO public.documents (client_id, project_name, title, description, content_md)
VALUES (
    'CLIENT_ID',
    'Project Name',
    'Document Title',
    'Description',
    '# Markdown content here...'
);
```

---

## Add Multiple Documents (Same Project)

```sql
INSERT INTO public.documents (client_id, project_name, title, description, content_md) VALUES
('CLIENT_ID', 'Project A', 'Doc 1', 'Desc 1', '# Content 1'),
('CLIENT_ID', 'Project A', 'Doc 2', 'Desc 2', '# Content 2'),
('CLIENT_ID', 'Project A', 'Doc 3', 'Desc 3', '# Content 3');
```

---

## Reply to Comment

```sql
INSERT INTO public.comments (document_id, user_id, content, is_owner)
VALUES ('DOC_ID', 'YOUR_USER_ID', 'Your reply...', true);
```

---

## View All Clients

```sql
SELECT c.*, u.email as auth_email, u.last_sign_in_at
FROM public.clients c
LEFT JOIN auth.users u ON c.user_id = u.id
ORDER BY c.created_at DESC;
```

---

## View Client's Documents

```sql
SELECT project_name, title, created_at, is_published
FROM public.documents
WHERE client_id = 'CLIENT_ID'
ORDER BY project_name, created_at DESC;
```

---

## Hide/Show Document

```sql
-- Hide
UPDATE public.documents SET is_published = false WHERE id = 'DOC_ID';

-- Show
UPDATE public.documents SET is_published = true WHERE id = 'DOC_ID';
```

---

## Delete Document

```sql
DELETE FROM public.documents WHERE id = 'DOC_ID';
```

---

## Common Issues

| Problem | Solution |
|---------|----------|
| Client sees "No projects" | Create `clients` record with their `user_id` |
| No magic link email | Check spam; verify Supabase Auth URLs |
| Document not visible | Check `is_published = true` and correct `client_id` |
