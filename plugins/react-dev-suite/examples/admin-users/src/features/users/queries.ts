import { queryOptions } from '@tanstack/react-query';
import { usersService } from './services';
import type { UserListParams } from './types';

export const userQueries = {
  list: (params?: UserListParams) =>
    queryOptions({
      queryKey: ['users', 'list', params],
      queryFn: () => usersService.getAll(params),
      placeholderData: prev => prev,
    }),

  detail: (id: string) =>
    queryOptions({
      queryKey: ['users', 'detail', id],
      queryFn: () => usersService.getById(id),
      enabled: Boolean(id),
    }),
};
