import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { orderQueries } from '../queries';
import { useOrderFilters, useOrderFilterActions } from '../store';
import { OrderStatusBadge } from './OrderStatusBadge';
import { CancelOrderForm } from './CancelOrderForm';
import type { Order, OrderStatus } from '../types';

const STATUS_OPTIONS: Array<{ value: OrderStatus | ''; label: string }> = [
  { value: '',           label: 'All statuses' },
  { value: 'pending',    label: 'Pending'    },
  { value: 'processing', label: 'Processing' },
  { value: 'shipped',    label: 'Shipped'    },
  { value: 'delivered',  label: 'Delivered'  },
  { value: 'cancelled',  label: 'Cancelled'  },
];

export function OrderList() {
  const filters          = useOrderFilters();
  const { setStatus, setSearch, setPage, resetFilters } = useOrderFilterActions();
  const [cancellingId, setCancellingId] = useState<string | null>(null);

  const { data, isLoading, isError } = useQuery(orderQueries.list(filters));

  if (isLoading) return <OrderListSkeleton />;
  if (isError)   return <p role="alert">Failed to load orders. Please try again.</p>;

  const orders = data?.data ?? [];
  const total  = data?.total ?? 0;

  return (
    <section aria-label="Order history">
      {/* Filters */}
      <div role="search">
        <label htmlFor="order-search" className="sr-only">Search orders</label>
        <input
          id="order-search"
          type="search"
          placeholder="Search orders…"
          value={filters.search}
          onChange={e => setSearch(e.target.value)}
        />

        <label htmlFor="order-status" className="sr-only">Filter by status</label>
        <select
          id="order-status"
          value={filters.status ?? ''}
          onChange={e => setStatus((e.target.value as OrderStatus) || undefined)}
        >
          {STATUS_OPTIONS.map(opt => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>

        <button type="button" onClick={resetFilters}>Clear filters</button>
      </div>

      {/* List */}
      {orders.length === 0 ? (
        <p>No orders found.</p>
      ) : (
        <ul aria-label={`${total} orders`}>
          {orders.map(order => (
            <OrderRow
              key={order.id}
              order={order}
              onCancel={() => setCancellingId(order.id)}
            />
          ))}
        </ul>
      )}

      {/* Pagination */}
      <nav aria-label="Order pagination">
        <button
          disabled={filters.page <= 1}
          onClick={() => setPage(filters.page - 1)}
        >
          Previous
        </button>
        <span>Page {filters.page}</span>
        <button
          disabled={!data || filters.page * (data.pageSize) >= total}
          onClick={() => setPage(filters.page + 1)}
        >
          Next
        </button>
      </nav>

      {/* Cancel modal */}
      {cancellingId && (
        <dialog open aria-modal aria-label="Cancel order">
          <CancelOrderForm
            orderId={cancellingId}
            onSuccess={() => setCancellingId(null)}
            onCancel={() => setCancellingId(null)}
          />
        </dialog>
      )}
    </section>
  );
}

interface OrderRowProps {
  order: Order;
  onCancel: () => void;
}

function OrderRow({ order, onCancel }: OrderRowProps) {
  return (
    <li>
      <span>#{order.id.slice(-6).toUpperCase()}</span>
      <OrderStatusBadge status={order.status} />
      <span>${order.total.toFixed(2)}</span>
      <time dateTime={order.createdAt}>
        {new Date(order.createdAt).toLocaleDateString()}
      </time>
      {order.status === 'pending' && (
        <button
          type="button"
          onClick={onCancel}
          aria-label={`Cancel order #${order.id.slice(-6).toUpperCase()}`}
        >
          Cancel order
        </button>
      )}
    </li>
  );
}

function OrderListSkeleton() {
  return (
    <ul aria-label="Loading orders" aria-busy>
      {Array.from({ length: 5 }).map((_, i) => (
        <li key={i} aria-hidden>Loading…</li>
      ))}
    </ul>
  );
}
