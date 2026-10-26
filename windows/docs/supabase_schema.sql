-- I Gede Pradhana Subawa Deningrat
-- 2415051030
-- TAHAP 11-12: schema tabel courses

create table public.courses (
  id         bigint generated always as identity primary key,
  code       text        not null,
  title      text        not null,
  credits    int         not null check (credits > 0),
  status     text        not null default 'planned'
             check (status in ('planned', 'active', 'done')),
  created_at timestamptz not null default now()
);

-- Aktifkan Row Level Security
alter table public.courses enable row level security;

-- Izin tingkat tabel untuk role anon (publishable key).
-- Tanpa ini, RLS policy saja tidak cukup (error 42501).
-- Hanya untuk laboratorium praktikum.
grant select, insert, update, delete
  on table public.courses
  to anon;

-- POLICY PERMISIF KHUSUS LABORATORIUM PRAKTIKUM.
-- Mengizinkan role anon (publishable key) membaca, menambah,
-- mengubah, dan menghapus. BUKAN pola produksi.
create policy "lab_select_courses" on public.courses
  for select to anon using (true);

create policy "lab_insert_courses" on public.courses
  for insert to anon with check (true);

create policy "lab_update_courses" on public.courses
  for update to anon using (true) with check (true);

create policy "lab_delete_courses" on public.courses
  for delete to anon using (true);

-- Data awal
insert into public.courses (code, title, credits, status) values
  ('MOB01', 'Git & GitHub',             2, 'done'),
  ('MOB02', 'Dart Fundamentals',        2, 'done'),
  ('MOB03', 'Flutter UI Fundamentals',  3, 'active'),
  ('MOB04', 'Navigation',               2, 'planned'),
  ('MOB05', 'State Management',         3, 'planned');