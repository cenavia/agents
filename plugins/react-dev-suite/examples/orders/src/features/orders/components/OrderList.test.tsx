import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@/test/utils';
import userEvent from '@testing-library/user-event';
import { http, HttpResponse } from 'msw';
import { server } from '@/test/mocks/server';
import { OrderList } from './OrderList';

const mockOrders = [
  {
    id: 'ord-aaa-001',
    status: 'pending',
    total: 49.99,
    items: [],
    shippingAddress: { street: '123 Main St', city: 'CDMX', state: 'MX', zipCode: '06600', country: 'MX' },
    createdAt: '2026-04-01T10:00:00Z',
    updatedAt: '2026-04-01T10:00:00Z',
  },
  {
    id: 'ord-bbb-002',
    status: 'delivered',
    total: 129.00,
    items: [],
    shippingAddress: { street: '456 Oak Ave', city: 'GDL', state: 'JA', zipCode: '44100', country: 'MX' },
    createdAt: '2026-03-15T08:00:00Z',
    updatedAt: '2026-03-20T14:00:00Z',
  },
];

beforeEach(() => {
  server.use(
    http.get('/api/orders', () =>
      HttpResponse.json({ data: mockOrders, total: 2, page: 1, pageSize: 10 }),
    ),
    http.patch('/api/orders/:id/cancel', () =>
      HttpResponse.json({ ...mockOrders[0], status: 'cancelled' }),
    ),
  );
});

describe('OrderList', () => {
  it('renders loading skeleton while fetching', () => {
    server.use(http.get('/api/orders', () => new Promise(() => {})));
    render(<OrderList />);
    expect(screen.getByRole('list', { name: /loading/i })).toBeInTheDocument();
  });

  it('renders orders after loading', async () => {
    render(<OrderList />);
    expect(await screen.findByRole('list', { name: /2 orders/i })).toBeInTheDocument();
    expect(screen.getAllByRole('listitem')).toHaveLength(2);
  });

  it('shows Cancel button only for pending orders', async () => {
    render(<OrderList />);
    await screen.findByRole('list', { name: /orders/i });

    // Only ord-aaa-001 is pending
    expect(screen.getAllByRole('button', { name: /cancel order/i })).toHaveLength(1);
    expect(screen.queryByRole('button', { name: /cancel order.*bbb/i })).not.toBeInTheDocument();
  });

  it('opens cancel dialog when Cancel button is clicked', async () => {
    const ue = userEvent.setup();
    render(<OrderList />);

    await screen.findByRole('list', { name: /orders/i });
    await ue.click(screen.getByRole('button', { name: /cancel order/i }));

    expect(screen.getByRole('dialog', { name: /cancel order/i })).toBeInTheDocument();
  });

  it('shows error alert when API fails', async () => {
    server.use(http.get('/api/orders', () => HttpResponse.json({}, { status: 500 })));
    render(<OrderList />);
    expect(await screen.findByRole('alert')).toHaveTextContent(/failed to load/i);
  });

  it('filters orders by status via select', async () => {
    const ue = userEvent.setup();
    server.use(
      http.get('/api/orders', ({ request }) => {
        const url = new URL(request.url);
        const status = url.searchParams.get('status');
        const filtered = status ? mockOrders.filter(o => o.status === status) : mockOrders;
        return HttpResponse.json({ data: filtered, total: filtered.length, page: 1, pageSize: 10 });
      }),
    );

    render(<OrderList />);
    await screen.findByRole('list', { name: /orders/i });

    await ue.selectOptions(screen.getByRole('combobox', { name: /status/i }), 'pending');

    await waitFor(() => {
      expect(screen.getByRole('list', { name: /1 orders/i })).toBeInTheDocument();
    });
  });

  it('has no accessibility violations', async () => {
    const { axe } = await import('jest-axe');
    const { container } = render(<OrderList />);
    await screen.findByRole('list', { name: /orders/i });
    expect(await axe(container)).toHaveNoViolations();
  });
});
