-- =====================================================================
-- WORKSHEET 9 - Authentication, Authorization (RLS) & Device Token
-- I Gede Pradhana Subawa Deningrat | 2415051030
--
-- Jalankan di Supabase > SQL Editor. Jalankan BAGIAN 1, 2, 3 berurutan.
-- Role pada project Course Manager:
--   student    = pencari/pembaca course (hanya melihat)         [seeker]
--   instructor = pemilik course (tambah/ubah/hapus course MILIKNYA) [owner]
--   admin      = mengelola seluruh data
-- =====================================================================


-- =====================================================================
-- BAGIAN 3 (Praktik 9, opsional) - Device registration untuk FCM
-- =====================================================================
create table if not exists public.device_tokens (
  token      text primary key,
  user_id    uuid not null default auth.uid()
             references auth.users(id) on delete cascade,
  platform   text,
  updated_at timestamptz not null default now()
);

alter table public.device_tokens enable row level security;
grant select, insert, update, delete on public.device_tokens to authenticated;

drop policy if exists "tokens_select_own" on public.device_tokens;
drop policy if exists "tokens_insert_own" on public.device_tokens;
drop policy if exists "tokens_update_own" on public.device_tokens;
drop policy if exists "tokens_delete_own" on public.device_tokens;

create policy "tokens_select_own" on public.device_tokens
  for select to authenticated using (auth.uid() = user_id);
create policy "tokens_insert_own" on public.device_tokens
  for insert to authenticated with check (auth.uid() = user_id);
create policy "tokens_update_own" on public.device_tokens
  for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "tokens_delete_own" on public.device_tokens
  for delete to authenticated using (auth.uid() = user_id);


