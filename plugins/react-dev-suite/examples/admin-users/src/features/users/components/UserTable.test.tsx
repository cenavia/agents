import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@/test/utils';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { server } from '@/test/mocks/server';
import { UserTable } from './UserTable';

const mockUsers = [
  { id: 'u1', name: 'Alice Admin', email: 'alice@test.com', role: 'admin',  status: 'active',   createdAt: '2026-01-01T00:00:00Z', lastLoginAt: '2026-05-01T00:00:00Z' },
  { id: 'u2', name: 'Bob Editor',  email: 'bob@test.com',   role: 'editor', status: 'active',   createdAt: '2026-02-01T00:00:00Z', lastLoginAt: null },
  { id: 'u3', name: 'Carol View',  email: 'carol@test.com', role: 'viewer', status: 'inactive', createdAt: '2026-03-01T00:00:00Z', lastLoginAt: null },
];

beforeEach(() => {
  server.use(
    http.get('/api/users', () =>
      HttpResponse.json({ data: mockUsers, total: 3, page: 1, pageSize: 10 }),
    ),
    http.patch('/api/users/:id/role',       ({ params }) => HttpResponse.json({ ...mockUsers.find(u => u.id === params.id), role: 'viewer' })),
    http.patch('/api/users/:id/deactivate', ({ params }) => HttpResponse.json({ ...mockUsers.find(u => u.id === params.id), status: 'inactive' })),
    http.patch('/api/users/:id/activate',   ({ params }) => HttpResponse.json({ ...mockUsers.find(u => u.id === params.id), status: 'active' })),
  );
});

describe('UserTable', () => {
  it('renders user list after loading', async () => {
    render(<UserTable />);
    expect(await screen.findByText('Alice Admin')).toBeInTheDocument();
    expect(screen.getByText('Bob Editor')).toBeInTheDocument();
    expect(screen.getByText('Carol View')).toBeInTheDocument();
  });

  it('shows "3 users found" count', async () => {
    render(<UserTable />);
    expect(await screen.findByText('3 users found')).toBeInTheDocument();
  });

  it('shows Deactivate for active users and Activate for inactive', async () => {
    render(<UserTable />);
    await screen.findByText('Alice Admin');

    const deactivateButtons = screen.getAllByRole('button', { name: /deactivate/i });
    const activateButtons   = screen.getAllByRole('button', { name: /activate carol/i });

    expect(deactivateButtons).toHaveLength(2); // Alice + Bob are active
    expect(activateButtons).toHaveLength(1);   // Carol is inactive
  });

  it('shows role select when Edit role button is clicked', async () => {
    const ue = userEvent.setup();
    render(<UserTable />);
    await screen.findByText('Alice Admin');

    await ue.click(screen.getByRole('button', { name: /edit role for alice/i }));

    expect(screen.getByRole('combobox', { name: /change role for alice/i })).toBeInTheDocument();
  });

  it('calls updateRole mutation when role is changed', async () => {
    const ue = userEvent.setup();
    render(<UserTable />);
    await screen.findByText('Alice Admin');

    await ue.click(screen.getByRole('button', { name: /edit role for alice/i }));
    await ue.selectOptions(screen.getByRole('combobox', { name: /change role for alice/i }), 'viewer');

    await waitFor(() => {
      expect(screen.queryByRole('combobox', { name: /change role/i })).not.toBeInTheDocument();
    });
  });

  it('shows error message when API fails', async () => {
    server.use(http.get('/api/users', () => HttpResponse.json({}, { status: 500 })));
    render(<UserTable />);
    expect(await screen.findByRole('alert')).toHaveTextContent(/failed to load/i);
  });

  it('has no accessibility violations', async () => {
    const { axe } = await import('jest-axe');
    const { container } = render(<UserTable />);
    await screen.findByText('Alice Admin');
    expect(await axe(container)).toHaveNoViolations();
  });
});
