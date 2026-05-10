export type OrderStatus = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled';

export interface Order {
  id: string;
  status: OrderStatus;
  total: number;
  items: OrderItem[];
  shippingAddress: ShippingAddress;
  createdAt: string;
  updatedAt: string;
}

export interface OrderItem {
  id: string;
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
}

export interface ShippingAddress {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
}

export interface OrderListParams {
  page?: number;
  pageSize?: number;
  status?: OrderStatus;
  search?: string;
  sortBy?: 'createdAt' | 'total' | 'status';
  sortDir?: 'asc' | 'desc';
}

export interface OrderListResponse {
  data: Order[];
  total: number;
  page: number;
  pageSize: number;
}

export interface CancelOrderDto {
  reason: string;
}
