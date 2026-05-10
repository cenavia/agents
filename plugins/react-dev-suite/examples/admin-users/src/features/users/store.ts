import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import type { UserRole, UserStatus } from './types';

interface UserFiltersState {
  search: string;
  role: UserRole | undefined;
  status: UserStatus | undefined;
  page: number;
  setSearch: (search: string) => void;
  setRole:   (role: UserRole | undefined) => void;
  setStatus: (status: UserStatus | undefined) => void;
  setPage:   (page: number) => void;
  resetFilters: () => void;
}

export const useUserFiltersStore = create<UserFiltersState>()(
  devtools(
    set => ({
      search: '',
      role:   undefined,
      status: undefined,
      page: 1,
      setSearch: search => set({ search, page: 1 }),
      setRole:   role   => set({ role,   page: 1 }),
      setStatus: status => set({ status, page: 1 }),
      setPage:   page   => set({ page }),
      resetFilters: ()  => set({ search: '', role: undefined, status: undefined, page: 1 }),
    }),
    { name: 'UserFiltersStore' },
  ),
);

export const useUserFilters      = () => useUserFiltersStore(s => ({ search: s.search, role: s.role, status: s.status, page: s.page }));
export const useUserFilterActions = () => useUserFiltersStore(s => ({ setSearch: s.setSearch, setRole: s.setRole, setStatus: s.setStatus, setPage: s.setPage, resetFilters: s.resetFilters }));
