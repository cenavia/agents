import { cn } from '@/lib/utils';
import type { OrderStatus } from '../types';

interface OrderStatusBadgeProps {
  status: OrderStatus;
  className?: string;
}

const STATUS_CONFIG: Record<OrderStatus, { label: string; classes: string }> = {
  pending:    { label: 'Pending',    classes: 'bg-yellow-100 text-yellow-800' },
  processing: { label: 'Processing', classes: 'bg-blue-100   text-blue-800'   },
  shipped:    { label: 'Shipped',    classes: 'bg-indigo-100 text-indigo-800' },
  delivered:  { label: 'Delivered',  classes: 'bg-green-100  text-green-800'  },
  cancelled:  { label: 'Cancelled',  classes: 'bg-red-100    text-red-800'    },
};

export function OrderStatusBadge({ status, className }: OrderStatusBadgeProps) {
  const { label, classes } = STATUS_CONFIG[status];
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
        classes,
        className,
      )}
    >
      {label}
    </span>
  );
}
