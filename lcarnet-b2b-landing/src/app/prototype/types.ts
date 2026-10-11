// ── Types for L'Carnet B2B Prototype ──

export type RoleType = "retailer" | "supplier" | "driver";
export type RetailerTab = "ledger" | "catalog" | "cart" | "orders" | "profile";
export type SupplierTab = "dashboard" | "inventory" | "clients" | "verifications" | "bids" | "profile";
export type DriverTab = "active" | "marketplace" | "profile";
export type LangType = "fr" | "ar";

export interface CartItem {
  id: string;
  name: string;
  nameAr?: string;
  brand: string;
  quantity: number;
  priceTiers: Record<string, number>;
}

export interface OrderItem {
  name: string;
  nameAr?: string;
  ordered: number;
  received: number;
  price: number;
}

export interface Order {
  id: string;
  date: string;
  dateAr: string;
  total: number;
  status: string;
  driverName: string;
  driverNameAr: string;
  pin: string;
  items: OrderItem[];
}

export interface Product {
  id: string;
  name: string;
  nameAr?: string;
  brand: string;
  stock: number;
  t1: number;
  t2: number;
  t3: number;
  status: string;
  compatibility: string[];
}

export interface Client {
  id: string;
  name: string;
  nameAr: string;
  city: string;
  cityAr: string;
  phone: string;
  balance: number;
  limit: number;
}

export interface PendingVerification {
  id: string;
  client: string;
  clientAr: string;
  method: string;
  ref: string;
  amount: number;
  date: string;
  dateAr: string;
}

export interface DeliveryBid {
  id: string;
  driver: string;
  driverAr: string;
  phone: string;
  amount: number;
  time: string;
  timeAr: string;
  mission: string;
  missionAr: string;
  status: string;
}

export interface DriverJob {
  id: string;
  from: string;
  to: string;
  fromAr: string;
  toAr: string;
  packages: string;
  packagesAr: string;
  estFee: number;
}
