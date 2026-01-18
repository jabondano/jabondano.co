-- =====================================================
-- SUPABASE SCHEMA FOR CLIENT PORTAL
-- jabondano.co/portal
-- =====================================================
-- Run this in your Supabase SQL Editor (supabase.com/dashboard)
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CLIENTS TABLE
-- Stores client information linked to auth.users
-- =====================================================
CREATE TABLE public.clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    company TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_clients_user_id ON public.clients(user_id);
CREATE INDEX idx_clients_email ON public.clients(email);

-- =====================================================
-- DOCUMENTS TABLE
-- Research documents you share with clients
-- =====================================================
CREATE TABLE public.documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    project_name TEXT, -- Group documents by project (e.g., "Q1 Research", "Strategy Review")
    content_md TEXT, -- Markdown content (for text documents)
    file_url TEXT,   -- Storage URL (for uploaded files)
    file_type TEXT DEFAULT 'markdown', -- 'markdown', 'pdf', 'image', etc.
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_documents_client_id ON public.documents(client_id);
CREATE INDEX idx_documents_created_at ON public.documents(created_at DESC);

-- =====================================================
-- CLIENT UPLOADS TABLE
-- Files uploaded by clients
-- =====================================================
CREATE TABLE public.client_uploads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID REFERENCES public.clients(id) ON DELETE CASCADE NOT NULL,
    document_id UUID REFERENCES public.documents(id) ON DELETE SET NULL, -- Optional: attach to a document
    filename TEXT NOT NULL,
    file_url TEXT NOT NULL,
    file_size INTEGER,
    file_type TEXT,
    notes TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_client_uploads_client_id ON public.client_uploads(client_id);

-- =====================================================
-- COMMENTS TABLE
-- Comments on documents (by you or clients)
-- =====================================================
CREATE TABLE public.comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID REFERENCES public.documents(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    is_owner BOOLEAN DEFAULT false, -- true if comment is from you (the owner)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_comments_document_id ON public.comments(document_id);
CREATE INDEX idx_comments_created_at ON public.comments(created_at);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- This ensures clients can only see their own data
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------
-- CLIENTS TABLE POLICIES
-- -----------------------------------------------------
-- Clients can only view their own profile
CREATE POLICY "Clients can view own profile"
    ON public.clients FOR SELECT
    USING (auth.uid() = user_id);

-- Clients can update their own profile
CREATE POLICY "Clients can update own profile"
    ON public.clients FOR UPDATE
    USING (auth.uid() = user_id);

-- -----------------------------------------------------
-- DOCUMENTS TABLE POLICIES
-- -----------------------------------------------------
-- Clients can only view documents shared with them
CREATE POLICY "Clients can view own documents"
    ON public.documents FOR SELECT
    USING (
        client_id IN (
            SELECT id FROM public.clients WHERE user_id = auth.uid()
        )
        AND is_published = true
    );

-- -----------------------------------------------------
-- CLIENT UPLOADS TABLE POLICIES
-- -----------------------------------------------------
-- Clients can view their own uploads
CREATE POLICY "Clients can view own uploads"
    ON public.client_uploads FOR SELECT
    USING (
        client_id IN (
            SELECT id FROM public.clients WHERE user_id = auth.uid()
        )
    );

-- Clients can insert uploads for themselves
CREATE POLICY "Clients can insert own uploads"
    ON public.client_uploads FOR INSERT
    WITH CHECK (
        client_id IN (
            SELECT id FROM public.clients WHERE user_id = auth.uid()
        )
    );

-- Clients can delete their own uploads
CREATE POLICY "Clients can delete own uploads"
    ON public.client_uploads FOR DELETE
    USING (
        client_id IN (
            SELECT id FROM public.clients WHERE user_id = auth.uid()
        )
    );

-- -----------------------------------------------------
-- COMMENTS TABLE POLICIES
-- -----------------------------------------------------
-- Clients can view comments on their documents
CREATE POLICY "Clients can view comments on own documents"
    ON public.comments FOR SELECT
    USING (
        document_id IN (
            SELECT d.id FROM public.documents d
            JOIN public.clients c ON d.client_id = c.id
            WHERE c.user_id = auth.uid()
        )
    );

-- Clients can insert comments on their documents
CREATE POLICY "Clients can insert comments on own documents"
    ON public.comments FOR INSERT
    WITH CHECK (
        document_id IN (
            SELECT d.id FROM public.documents d
            JOIN public.clients c ON d.client_id = c.id
            WHERE c.user_id = auth.uid()
        )
        AND user_id = auth.uid()
    );

-- Clients can update their own comments
CREATE POLICY "Clients can update own comments"
    ON public.comments FOR UPDATE
    USING (user_id = auth.uid());

-- Clients can delete their own comments
CREATE POLICY "Clients can delete own comments"
    ON public.comments FOR DELETE
    USING (user_id = auth.uid());

-- =====================================================
-- STORAGE BUCKETS
-- Run these in SQL or create manually in Storage settings
-- =====================================================

-- Create storage bucket for documents (your uploads)
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for client uploads
INSERT INTO storage.buckets (id, name, public)
VALUES ('client-uploads', 'client-uploads', false)
ON CONFLICT (id) DO NOTHING;

-- -----------------------------------------------------
-- STORAGE POLICIES
-- -----------------------------------------------------

-- Documents bucket: Clients can read files for their documents
CREATE POLICY "Clients can read own document files"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'documents'
        AND (storage.foldername(name))[1] IN (
            SELECT c.id::text FROM public.clients c WHERE c.user_id = auth.uid()
        )
    );

-- Client uploads bucket: Clients can read their own uploads
CREATE POLICY "Clients can read own uploads"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'client-uploads'
        AND (storage.foldername(name))[1] IN (
            SELECT c.id::text FROM public.clients c WHERE c.user_id = auth.uid()
        )
    );

-- Client uploads bucket: Clients can upload to their folder
CREATE POLICY "Clients can upload to own folder"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'client-uploads'
        AND (storage.foldername(name))[1] IN (
            SELECT c.id::text FROM public.clients c WHERE c.user_id = auth.uid()
        )
    );

-- Client uploads bucket: Clients can delete their own files
CREATE POLICY "Clients can delete own files"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'client-uploads'
        AND (storage.foldername(name))[1] IN (
            SELECT c.id::text FROM public.clients c WHERE c.user_id = auth.uid()
        )
    );

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to tables
CREATE TRIGGER set_clients_updated_at
    BEFORE UPDATE ON public.clients
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_documents_updated_at
    BEFORE UPDATE ON public.documents
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_comments_updated_at
    BEFORE UPDATE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- ADMIN SERVICE ROLE ACCESS
-- These allow you to manage all data via service key
-- (Used by Claude Code for uploads)
-- =====================================================

-- Note: When using the service_role key (not anon key),
-- RLS is bypassed automatically, so you can:
-- 1. Create clients
-- 2. Upload documents for any client
-- 3. Manage all data

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Uncomment to create a test client after they sign up:
-- INSERT INTO public.clients (user_id, name, email, company)
-- VALUES (
--     'user-uuid-from-auth',  -- Replace with actual user ID from auth.users
--     'Test Client',
--     'client@example.com',
--     'Test Company'
-- );

-- Uncomment to create a test document:
-- INSERT INTO public.documents (client_id, title, description, content_md)
-- VALUES (
--     'client-uuid',  -- Replace with actual client ID
--     'Research Report Q1 2024',
--     'Quarterly analysis and recommendations',
--     '# Research Report\n\n## Summary\n\nKey findings...'
-- );
