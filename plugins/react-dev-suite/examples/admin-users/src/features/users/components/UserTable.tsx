import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { userQueries } from '../queries';
import { useUserFilters, useUserFilterActions } from '../store';
import { useUpdateUserRole, useDeactivateUser, useActivateUser } from '../mutations';
import type { User, UserRole, UserStatus } from '../types';

const ROLES:    UserRole[]   = ['admin', 'editor', 'viewer'];
const STATUSES: UserStatus[] = ['active', 'inactive'];

export function UserTable() {
  const filters          = useUserFilters();
  const { setSearch, setRole, setStatus, setPage, resetFilters } = useUserFilterActions();
  const [editingRoleId, setEditingRoleId] = useState<string | null>(null);

  const updateRole   = useUpdateUserRole();
  const deactivate   = useDeactivateUser();
  const activate     = useActivateUser();

  const { data, isLoading, isError } = useQuery(userQueries.list(filters));

  async function handleRoleChange(userId: string, role: UserRole) {
    await updateRole.mutateAsync({ id: userId, dto: { role } });
    setEditingRoleId(null);
  }

  async function handleToggleStatus(user: User) {
    if (user.status === 'active') {
      await deactivate.mutateAsync(user.id);
    } else {
      await activate.mutateAsync(user.id);
    }
  }

  if (isLoading) return <p aria-busy>Loading users…</p>;
  if (isError)   return <p role="alert">Failed to load users.</p>;

  const users = data?.data ?? [];
  const total = data?.total ?? 0;

  return (
    <section aria-label="User management">
      {/* Search & Filters */}
      <div role="search">
        <label htmlFor="user-search" className="sr-only">Search users</label>
        <input
          id="user-search"
          type="search"
          placeholder="Search by name or email…"
          value={filters.search}
          onChange={e => setSearch(e.target.value)}
        />

        <label htmlFor="role-filter" className="sr-only">Filter by role</label>
        <select
          id="role-filter"
          value={filters.role ?? ''}
          onChange={e => setRole((e.target.value as UserRole) || undefined)}
        >
          <option value="">All roles</option>
          {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
        </select>

        <label htmlFor="status-filter" className="sr-only">Filter by status</label>
        <select
          id="status-filter"
          value={filters.status ?? ''}
          onChange={e => setStatus((e.target.value as UserStatus) || undefined)}
        >
          <option value="">All statuses</option>
          {STATUSES.map(s => <option key={s} value={s}>{s}</option>)}
        </select>

        <button type="button" onClick={resetFilters}>Clear</button>
      </div>

      <p>{total} users found</p>

      {/* Table */}
      <table>
        <caption className="sr-only">Registered users</caption>
        <thead>
          <tr>
            <th scope="col">Name</th>
            <th scope="col">Email</th>
            <th scope="col">Role</th>
            <th scope="col">Status</th>
            <th scope="col">Last login</th>
            <th scope="col"><span className="sr-only">Actions</span></th>
          </tr>
        </thead>
        <tbody>
          {users.map(user => (
            <tr key={user.id}>
              <td>{user.name}</td>
              <td>{user.email}</td>
              <td>
                {editingRoleId === user.id ? (
                  <select
                    aria-label={`Change role for ${user.name}`}
                    defaultValue={user.role}
                    onChange={e => handleRoleChange(user.id, e.target.value as UserRole)}
                    onBlur={() => setEditingRoleId(null)}
                    autoFocus
                  >
                    {ROLES.map(r => <option key={r} value={r}>{r}</option>)}
                  </select>
                ) : (
                  <button
                    type="button"
                    onClick={() => setEditingRoleId(user.id)}
                    aria-label={`Edit role for ${user.name}: currently ${user.role}`}
                  >
                    {user.role}
                  </button>
                )}
              </td>
              <td>
                <span aria-label={`Status: ${user.status}`}>{user.status}</span>
              </td>
              <td>
                {user.lastLoginAt
                  ? <time dateTime={user.lastLoginAt}>{new Date(user.lastLoginAt).toLocaleDateString()}</time>
                  : 'Never'}
              </td>
              <td>
                <button
                  type="button"
                  onClick={() => handleToggleStatus(user)}
                  aria-label={`${user.status === 'active' ? 'Deactivate' : 'Activate'} ${user.name}`}
                  disabled={deactivate.isPending || activate.isPending}
                >
                  {user.status === 'active' ? 'Deactivate' : 'Activate'}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Pagination */}
      <nav aria-label="User pagination">
        <button disabled={filters.page <= 1} onClick={() => setPage(filters.page - 1)}>Previous</button>
        <span>Page {filters.page}</span>
        <button disabled={!data || filters.page * data.pageSize >= total} onClick={() => setPage(filters.page + 1)}>Next</button>
      </nav>
    </section>
  );
}
