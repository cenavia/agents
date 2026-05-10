import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ordersService } from './services';
import type { CancelOrderDto } from './types';

export function useCancelOrder() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: string; dto: CancelOrderDto }) =>
      ordersService.cancel(id, dto),
    onSuccess: cancelled => {
      qc.invalidateQueries({ queryKey: ['orders', 'list'] });
      qc.setQueryData(
        ['orders', 'detail', cancelled.id],
        cancelled,
      );
    },
  });
}
