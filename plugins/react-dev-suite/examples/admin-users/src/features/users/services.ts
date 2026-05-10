import { api } from '@/lib/api';
import type {
  User,
  UserListParams,
  UserListResponse,
  UpdateUserRoleDto,
  UpdateUserStatusDto,
} from './types';

const BASE = '/users';

export const usersService = {
  getAll: (params?: UserListParams) =>
    api.get<UserListResponse>(BASE, { params }).then(r => r.data),

  getById: (id: string) =>
    api.get<User>(`${BASE}/${id}`).then(r => r.data),

  updateRole: (id: string, dto: UpdateUserRoleDto) =>
    api.patch<User>(`${BASE}/${id}/role`, dto).then(r => r.data),

  deactivate: (id: string) =>
    api.patch<User>(`${BASE}/${id}/deactivate`).then(r => r.data),

  activate: (id: string) =>
    api.patch<User>(`${BASE}/${id}/activate`).then(r => r.data),
};
