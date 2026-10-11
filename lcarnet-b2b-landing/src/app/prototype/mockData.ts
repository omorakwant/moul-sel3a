import {
  CartItem,
  Order,
  Product,
  Client,
  PendingVerification,
  DeliveryBid,
  DriverJob,
} from "./types";

export const initialCart: CartItem[] = [
    {
      id: "prod-001",
      name: "Coque Silicone iPhone 13/14",
      nameAr: "بوشيطة سيليكون ايفون 13/14",
      brand: "Generic",
      quantity: 10,
      priceTiers: { "1": 15.0, "10": 12.0, "50": 10.0 },
    },
    {
      id: "prod-002",
      name: "Verre Trempé Samsung A54 (9H)",
      nameAr: "زجاج واقي سامسونغ A54 (9H)",
      brand: "GlassPro",
      quantity: 20,
      priceTiers: { "1": 25.0, "10": 20.0, "50": 16.0 },
    },
  ];

export const initialOrders: Order[] = [
    {
      id: "CMD-2026-84",
      date: "Aujourd'hui, 09:30",
      dateAr: "اليوم، 09:30",
      total: 1850.0,
      status: "in_transit",
      driverName: "Kourtia Hassan (+212 6 98 00 00 01)",
      driverNameAr: "كورتي حسن (+212 6 98 00 00 01)",
      pin: "4829",
      items: [
        { name: "Coque Silicone iPhone 13/14", nameAr: "بوشيطة سيليكون ايفون 13/14", ordered: 20, received: 20, price: 12.0 },
        { name: "Chargeur Rapide USB-C 20W", nameAr: "شارجور سريع تايب-سي 20W", ordered: 15, received: 15, price: 38.0 },
      ],
    },
    {
      id: "CMD-2026-72",
      date: "Hier, 16:15",
      dateAr: "البارح، 16:15",
      total: 2900.75,
      status: "delivered",
      driverName: "Livreur Omar",
      driverNameAr: "عمر كورتي",
      pin: "1192",
      items: [
        { name: "Écouteurs Bluetooth TWS", nameAr: "ليزيكوتور بلوتوث TWS", ordered: 25, received: 25, price: 72.0 },
        { name: "Câble Data USB-C vers Lightning", nameAr: "كابل داتا تايب-سي لايتنينغ", ordered: 40, received: 40, price: 18.0 },
      ],
    },
  ];

export const initialProducts: Product[] = [
    {
      id: "prod-001",
      name: "Coque Silicone iPhone 13/14",
      nameAr: "بوشيطة سيليكون ايفون 13/14",
      brand: "Generic",
      stock: 200,
      t1: 15.0,
      t2: 12.0,
      t3: 10.0,
      status: "Actif",
      compatibility: ["iPhone 13", "iPhone 14"],
    },
    {
      id: "prod-002",
      name: "Verre Trempé Samsung A54 (9H)",
      nameAr: "زجاج واقي سامسونغ A54 (9H)",
      brand: "GlassPro",
      stock: 150,
      t1: 25.0,
      t2: 20.0,
      t3: 16.0,
      status: "Actif",
      compatibility: ["Samsung A54", "Samsung A34"],
    },
    {
      id: "prod-003",
      name: "Chargeur Rapide USB-C 20W",
      nameAr: "شارجور سريع تايب-سي 20 واط",
      brand: "PowerMax",
      stock: 80,
      t1: 45.0,
      t2: 38.0,
      t3: 32.0,
      status: "Actif",
      compatibility: ["iPhone 13", "iPhone 14", "Samsung A54"],
    },
    {
      id: "prod-004",
      name: "Câble Data USB-C vers Lightning",
      nameAr: "كابل داتا تايب-سي لايتنينغ",
      brand: "CablePlus",
      stock: 300,
      t1: 22.0,
      t2: 18.0,
      t3: 14.0,
      status: "Actif",
      compatibility: ["iPhone 11", "iPhone 12", "iPhone 13", "iPhone 14"],
    },
    {
      id: "prod-005",
      name: "Écouteurs Bluetooth TWS",
      nameAr: "ليزيكوتور بلوتوث TWS",
      brand: "SoundBox",
      stock: 60,
      t1: 85.0,
      t2: 72.0,
      t3: 60.0,
      status: "Actif",
      compatibility: ["Tous les modèles"],
    },
  ];

export const initialClients: Client[] = [
    { id: "c1", name: "Hanout Moulay", nameAr: "حانوت مولاي", city: "Rabat (Souk Al Had)", cityAr: "الرباط (سوق الأحد)", phone: "+212 6 61 00 00 01", balance: 4250.75, limit: 15000 },
    { id: "c2", name: "Téléphonie Fès", nameAr: "تيليفونات فاس", city: "Fès (Médina)", cityAr: "فاس (المدينة)", phone: "+212 6 61 00 00 02", balance: 1200.0, limit: 8000 },
    { id: "c3", name: "Hanout Bab Marrakech", nameAr: "حانوت باب مراكش", city: "Casablanca", cityAr: "الدار البيضاء", phone: "+212 6 61 00 00 03", balance: 8450.0, limit: 20000 },
    { id: "c4", name: "SmartPhone Tanger", nameAr: "سمارتفون طنجة", city: "Tanger (Boulevard)", cityAr: "طنجة (البولفار)", phone: "+212 6 61 00 00 04", balance: 0.0, limit: 12000 },
  ];

export const initialPendingVerifications: PendingVerification[] = [
    {
      id: "pv-001",
      client: "Hanout Moulay",
      clientAr: "حانوت مولاي",
      method: "Wafacash",
      ref: "WF-2026-9814",
      amount: 1200.0,
      date: "Aujourd'hui, 11:20",
      dateAr: "اليوم، 11:20",
    },
    {
      id: "pv-002",
      client: "Téléphonie Fès",
      clientAr: "تيليفونات فاس",
      method: "CashPlus",
      ref: "CP-2026-4412",
      amount: 500.0,
      date: "Hier, 18:45",
      dateAr: "البارح، 18:45",
    },
  ];

export const initialDeliveryBids: DeliveryBid[] = [
    { id: "bid-1", driver: "Kourtia Hassan", driverAr: "كورتي حسن", phone: "+212 6 98 00 00 01", amount: 85, time: "2 heures", timeAr: "ساعتين", mission: "Derb Omar ➔ Souk Al Had, Rabat", missionAr: "درب عمر ➔ سوق الأحد، الرباط", status: "pending" },
    { id: "bid-2", driver: "Livreur Omar", driverAr: "عمر كورتي", phone: "+212 6 98 00 00 02", amount: 95, time: "3 heures", timeAr: "3 سوايع", mission: "Derb Omar ➔ Souk Al Had, Rabat", missionAr: "درب عمر ➔ سوق الأحد، الرباط", status: "pending" },
  ];

export const initialDriverJobs: DriverJob[] = [
    { id: "job-1", from: "Garage Allal, Casa", to: "Médina, Fès", fromAr: "كراج علال، كازا", toAr: "المدينة القديمة، فاس", packages: "3 cartons (Écrans)", packagesAr: "3 كراطن (إكرانات)", estFee: 140 },
    { id: "job-2", from: "Derb Ghallef, Casa", to: "Océan, Rabat", fromAr: "درب غلف، كازا", toAr: "المحيط، الرباط", packages: "1 carton (Chargeurs)", packagesAr: "1 كرطونة (شارجورات)", estFee: 75 },
    { id: "job-3", from: "Derb Omar, Casa", to: "Gueliz, Marrakech", fromAr: "درب عمر، كازا", toAr: "كيليز، مراكش", packages: "4 cartons", packagesAr: "4 كراطن", estFee: 180 },
  ];
