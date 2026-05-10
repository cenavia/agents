import { api } from '@/lib/api';
import type {
  Order,
  OrderListParams,
  OrderListResponse,
  CancelOrderDto,
} from './types';

const BASE = '/orders';

export const ordersService = {
  getAll: (params?: OrderListParams) =>
    api.get<OrderListResponse>(BASE, { params }).then(r => r.data),

  getById: (id: string) =>
    api.get<Order>(`${BASE}/${id}`).then(r => r.data),

  cancel: (id: string, dto: CancelOrderDto) =>
    api.patch<Order>(`${BASE}/${id}/cancel`, dto).then(r => r.data),
};
