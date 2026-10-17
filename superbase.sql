-- 1. 创建待办表
create table public.todos (
  id uuid default uuid_generate_v4() primary key,
  title text not null,
  is_completed boolean default false,
  user_id uuid references auth.users(id) not null default auth.uid(),
  created_at timestamp with time zone default now()
);

-- 2. 开启行级安全
alter table public.todos enable row level security;

-- 3. 回收默认权限，只给登录用户授权
revoke all on public.todos from anon, authenticated;
grant select, insert, update, delete on public.todos to authenticated;

-- 4. RLS策略：登录用户只能读取自己的待办
create policy "read own todos"
on public.todos for select
to authenticated
using (auth.uid() = user_id);

-- 5. 只能插入属于自己的待办
create policy "insert own todos"
on public.todos for insert
to authenticated
with check (auth.uid() = user_id);

-- 6. 只能更新自己的待办
create policy "update own todos"
on public.todos for update
to authenticated
using (auth.uid() = user_id);

-- 7. 只能删除自己的待办
create policy "delete own todos"
on public.todos for delete
to authenticated
using (auth.uid() = user_id);
