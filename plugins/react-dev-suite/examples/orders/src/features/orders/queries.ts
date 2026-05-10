import { queryOptions, infiniteQueryOptions } from '@tanstack/react-query';
import { ordersService } from './services';
import type { OrderListParams } from './types';

export const orderQueries = {
  list: (params?: OrderListParams) =>
    queryOptions({
      queryKey: ['orders', 'list', params],
      queryFn: () => ordersService.getAll(params),
      placeholderData: prev => prev,
    }),

  detail: (id: string) =>
    queryOptions({
      queryKey: ['orders', 'detail', id],
      queryFn: () => ordersService.getById(id),
      enabled: Boolean(id),
    }),

  infinite: (params?: Omit<OrderListParams, 'page'>) =>
    infiniteQueryOptions({
      queryKey: ['orders', 'list', 'infinite', params],
      queryFn: ({ pageParam = 1 }) =>
        ordersService.getAll({ ...params, page: pageParam as number }),
      getNextPageParam: last =>
        last.page * last.pageSize < last.total ? last.page + 1 : undefined,
      initialPageParam: 1,
    }),
};
