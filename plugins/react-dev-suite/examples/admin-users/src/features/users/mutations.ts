import { useMutation, useQueryClient } from '@tanstack/react-query';
import { usersService } from './services';
import type { UpdateUserRoleDto } from './types';

function useUserMutation(mutationFn: (id: string) => Promise<import('./types').User>) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn,
    onSuccess: updated => {
      qc.invalidateQueries({ queryKey: ['users', 'list'] });
      qc.setQueryData(['users', 'detail', updated.id], updated);
    },
  });
}

export function useUpdateUserRole() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: string; dto: UpdateUserRoleDto }) =>
      usersService.updateRole(id, dto),
    onSuccess: updated => {
      qc.invalidateQueries({ queryKey: ['users', 'list'] });
      qc.setQueryData(['users', 'detail', updated.id], updated);
    },
  });
}

export function useDeactivateUser() {
  return useUserMutation(id => usersService.deactivate(id));
}

export function useActivateUser() {
  return useUserMutation(id => usersService.activate(id));
}
