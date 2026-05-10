import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import type { OrderStatus } from './types';

interface OrderFiltersState {
  status: OrderStatus | undefined;
  search: string;
  page: number;
  setStatus: (status: OrderStatus | undefined) => void;
  setSearch: (search: string) => void;
  setPage: (page: number) => void;
  resetFilters: () => void;
}

export const useOrderFiltersStore = create<OrderFiltersState>()(
  devtools(
    set => ({
      status: undefined,
      search: '',
      page: 1,
      setStatus: status => set({ status, page: 1 }),
      setSearch: search => set({ search, page: 1 }),
      setPage:   page   => set({ page }),
      resetFilters: ()  => set({ status: undefined, search: '', page: 1 }),
    }),
    { name: 'OrderFiltersStore' },
  ),
);

// Granular selectors — prevent re-renders on unrelated filter changes
export const useOrderFilters     = () => useOrderFiltersStore(s => ({ status: s.status, search: s.search, page: s.page }));
export const useOrderFilterActions = () => useOrderFiltersStore(s => ({ setStatus: s.setStatus, setSearch: s.setSearch, setPage: s.setPage, resetFilters: s.resetFilters }));
