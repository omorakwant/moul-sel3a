# DESIGN_CONTEXT.md
## Master Design Specification: "L'Carnet B2B" (Mobile & Web System)

**Role:** Expert UI/UX Designer for Emerging Markets (Morocco)  
**Goal:** Create a high-fidelity, production-ready design system for a B2B app connecting Wholesalers, Retailers, and Drivers.  
**Core Constraint:** All mobile screens MUST use a fixed **390x844 (iPhone 15)** viewport. Do not create "long infinite" pages. Use **Scrollable Areas** within the fixed frame.

---

## 1. Visual Identity & Design System

### Typography
- **Primary Font:** Inter or Roboto
- **Minimum Body Text Size:** 16px for readability in sunlight
- **Font Hierarchy:**
  - Headings: **Manrope** — 700–800 weight
  - Body/Content: **Inter** — 400–600 weight
- **Special Consideration:** Large, legible fonts optimized for outdoor usage and busy market environments

### Color Palette

#### Primary Colors
| Token | Hex | Usage |
|-------|-----|-------|
| **Primary** | `#4F46E5` (Deep Indigo) | Trust & Business — primary brand color, headers, key CTAs |
| **Action/Success** | `#10B981` (Emerald Green) | Money & Confirmation — positive balance, success states, confirmed actions |
| **Debt/Alert** | `#E11D48` (Rose Red) | Negative Balance/Errors — debt indicators, warnings, critical alerts |
| **Background** | `#F8FAFC` (Slate Gray) | Clean, low glare — main background for all screens |

#### Supporting Colors
| Token | Hex | Usage |
|-------|-----|-------|
| **Surface** | `#FFFFFF` (White) | Card backgrounds, elevated surfaces |
| **Border** | `#E2E8F0` | Subtle borders, dividers |
| **Text Primary** | `#1E293B` | Main content text |
| **Text Secondary** | `#64748B` | Secondary information, metadata |
| **Text Tertiary** | `#94A3B8` | Hints, disabled states |

#### Status Badge Colors
| Status | Background | Foreground | Usage |
|--------|------------|------------|-------|
| Open | `#DBEAFE` | `#1E40AF` | Supplier is available |
| Closed | `#FEE2E2` | `#991B1B` | Supplier is unavailable |
| Credit | `#D1FAE5` | `#065F46` | Positive balance (retailer has credit) |
| Debt | `#FEE2E2` | `#991B1B` | Negative balance (retailer owes money) |

### Components & Touch Targets
- **Minimum Touch Target:** 48px height (iOS Human Interface Guidelines)
- **Reason:** "Fat finger" usage in busy markets — users often have gloves, wet hands, or limited precision
- **Button Padding:** 14px vertical, 24px horizontal minimum
- **Card Corner Radius:** 16px for main cards, 12px for smaller elements
- **Icon Size:** Minimum 24px for interactive icons

### Layout Grid
- **Viewport:** 390px × 844px (fixed)
- **Safe Area Padding:** 16px horizontal margins
- **Content Width:** 358px (390 - 32)
- **Vertical Rhythm:** 8px base unit (spacing multiples: 8, 16, 24, 32, 40)

---

## 2. Mobile Screens (Retailer & Driver) — Viewport: 390×844

### Screen A: Retailer Home (The "Carnet" Dashboard)

**Purpose:** Multi-supplier overview showing all business relationships and balances at a glance.

#### Layout Specification

**Header (Static — 64px height)**
- Left: "Salam, [Shop Name]" — 18px, weight 700, color `#1E293B`
- Right: Location Icon + City Name — 14px, weight 500, color `#64748B`
- Background: `#F8FAFC`
- Bottom Border: 1px solid `#E2E8F0`

**Body (Scrollable — 716px height, scrolls vertically)**
- **Grid of Supplier Cards**
  - Layout: 2-column grid (gap: 12px)
  - Card Dimensions: 173px width × 180px height
  - Card Background: `#FFFFFF`
  - Card Border: 1px solid `#E2E8F0`
  - Card Corner Radius: 16px
  - Card Padding: 16px

**Supplier Card Anatomy:**
```
┌────────────────────────────┐
│  [Logo]    Status Badge    │ ← Top Row (32px logo + badge)
│            [Open/Closed]    │
│                             │
│  Business Name              │ ← 16px, weight 600
│  (2 lines max, ellipsis)    │
│                             │
│  Solde Actuel              │ ← 12px, weight 500, #64748B
│  2,450.00 DH               │ ← 22px, weight 700
│                             │
│  [Pay]    [Shop]           │ ← Action buttons (48px height)
└────────────────────────────┘
```

**Card Logic:**
- **Balance > 0 (Credit):**
  - Amount Color: `#10B981` (Emerald Green)
  - Label: "Crédit Actuel" / "كريدي ديالك"
  
- **Balance < 0 (Debt):**
  - Amount Color: `#E11D48` (Rose Red)
  - Label: "À Payer" / "خصك تخلص"

- **Status Badge:**
  - "Open" → Background `#DBEAFE`, Text `#1E40AF`
  - "Closed" → Background `#FEE2E2`, Text `#991B1B`

**Bottom Navigation Bar (64px height)**
- 3 Tabs: Home | Orders | Profile
- Selected Color: `#4F46E5` (Deep Indigo)
- Unselected Color: `#94A3B8`
- Icon Size: 24px
- Label: 11px, weight 500

**Total Screen Height Breakdown:**
- Header: 64px
- Body: 716px (scrollable)
- Bottom Nav: 64px
- **Total: 844px ✓**

---

### Screen B: The Smart Catalog (Tiered Pricing)

**Purpose:** Product discovery with compatibility-first filtering and dynamic pricing display.

#### Layout Specification

**Header (Static — 120px height)**
- **Search Bar (56px height)**
  - Background: `#FFFFFF`
  - Border: 1px solid `#E2E8F0`
  - Corner Radius: 14px
  - Placeholder: "Rechercher par modèle..." / "قلب بالموديل"
  - Left Icon: Search (24px)
  - Right Icon: Voice/Mic (24px, tappable)
  - Padding: 14px horizontal

- **Filter Chips (48px height)**
  - Horizontal scroll carousel
  - Chip Height: 36px
  - Chip Padding: 12px horizontal
  - Gap: 8px
  - Examples: "iPhone" | "Samsung" | "Xiaomi" | "Accessories"
  - Selected: Background `#4F46E5`, Text `#FFFFFF`
  - Unselected: Background `#FFFFFF`, Text `#64748B`, Border `#E2E8F0`

- Vertical Spacing: 16px between search and chips

**Body (Scrollable — 660px height, scrolls vertically)**
- **Product List View**
  - Card Height: 120px
  - Card Background: `#FFFFFF`
  - Card Border: 1px solid `#E2E8F0`
  - Card Corner Radius: 12px
  - Vertical Gap: 12px
  - Padding: 16px horizontal in container

**Product Card Anatomy:**
```
┌──────────────────────────────────────┐
│ [Image]  Title (1 line)    [+ ADD]  │ ← Top Row
│  80px    16px, weight 600    48px   │
│          Color: #1E293B              │
│                                      │
│         Stock: "12 units"            │ ← Badge (if needed)
│         14px, #64748B                │
│                                      │
│         Prix Unitaire: 45.00 DH     │ ← Base price (18px, bold)
│         Buy 10+: 43.00 DH (-2 DH)   │ ← Tier hint (14px, #10B981)
└──────────────────────────────────────┘
```

**Pricing Logic Display:**
- Show **Unit Price** (Tier 1) prominently: 18px, weight 700, color `#1E293B`
- Below it: "Buy 10+ for 43.00 DH" — 14px, weight 500, color `#10B981`
- If user has items in cart for this product, show quantity stepper instead of [+] button

**Add to Cart Action:**
- **State 1 (No items):** Large green [+] button (48px × 48px)
  - Background: `#10B981`
  - Icon: Plus (24px, white)
  
- **State 2 (Items in cart):** Quantity Stepper
  - Layout: [-] [3] [+]
  - Button Size: 32px × 32px each
  - Background: `#4F46E5`
  - Text: 16px, weight 700, white
  - Total Width: 104px

**Sticky Footer Bar (64px height)**
- Background: `#4F46E5` (Deep Indigo)
- Fixed at bottom above nav bar
- Layout:
  ```
  ┌──────────────────────────────────┐
  │  3 Items    Voir Panier  450 DH │
  │  (Left)     (Center)     (Right) │
  └──────────────────────────────────┘
  ```
- Text Color: `#FFFFFF`
- Button: "Voir Panier" — 48px height, rounded corners
- Amount: 20px, weight 700

**Total Screen Height Breakdown:**
- Header: 120px
- Body: 660px (scrollable)
- Sticky Footer: 64px
- **Total: 844px ✓**

---

### Screen C: Checkout & Partial Receipt (The "Handshake")

**Purpose:** Order verification at delivery with partial receipt adjustment capability.

#### Layout Specification

**Header (Static — 64px height)**
- Title: "Vérification de la Commande #1024"
- Font: 18px, weight 700, color `#1E293B`
- Background: `#F8FAFC`
- Bottom Border: 1px solid `#E2E8F0`

**Body (Scrollable — 652px height)**
- **Order Item List**
  - Each row height: ~80px (dynamic based on content)
  - Row Background: `#FFFFFF`
  - Row Border: 1px solid `#E2E8F0`
  - Row Corner Radius: 12px
  - Vertical Gap: 8px
  - Padding: 12px

**Order Item Row Anatomy:**
```
┌──────────────────────────────────────┐
│ Cable USB-C                          │ ← Product Name (16px)
│ Ordered: 10 pcs                      │ ← Original quantity
│                                      │
│ Received: [-] [10] [+]              │ ← Stepper
│                                      │
│ Unit: 15.00 DH | Total: 150.00 DH  │ ← Price info
└──────────────────────────────────────┘
```

**Interaction Logic:**
- If user reduces quantity (e.g., 10 → 8):
  - Row Background: `#FEF3C7` (Amber/Warning)
  - Show "Reason" dropdown below stepper
  - Options: "Broken" | "Missing" | "Wrong Item"
  - Dropdown: 14px, background `#FFFFFF`, border `#D97706`

- If user increases quantity above ordered:
  - Disable [+] button
  - Show tooltip: "Cannot receive more than ordered"

**Sticky Footer (128px height)**
- Background: `#FFFFFF`
- Top Border: 2px solid `#E2E8F0`
- Padding: 16px

**Footer Layout:**
```
┌──────────────────────────────────────┐
│ Total Original:       5,000.00 DH   │ ← 14px, #64748B
│ Total Final:          4,800.00 DH   │ ← 18px, #1E293B, bold
│ Difference:            -200.00 DH   │ ← 14px, #E11D48
│                                      │
│ ┌──────────────────────────────────┐│
│ │ Confirmer la Réception (PIN)     ││ ← Full-width button
│ └──────────────────────────────────┘│    56px height, #10B981
└──────────────────────────────────────┘
```

**PIN Entry Modal (triggered by button):**
- Centered overlay (320px × 280px)
- Background: `#FFFFFF`, shadow
- Title: "Entrez le PIN du Livreur"
- 4-digit PIN input (large numeric boxes)
- Buttons: "Annuler" | "Confirmer"

**Total Screen Height Breakdown:**
- Header: 64px
- Body: 652px (scrollable)
- Sticky Footer: 128px
- **Total: 844px ✓**

---

### Screen D: Payment Declaration (Wafacash Proof)

**Purpose:** Retailer declares payment with receipt photo and reference code.

#### Layout Specification

**Header (Static — 64px height)**
- Title: "Déclarer un Paiement" / "خلصت شوية"
- Subtitle: "Fournisseur: [Supplier Name] | À payer: 2,500 DH"
- Font: 16px / 14px, weights 700/500
- Background: `#F8FAFC`

**Body (Scrollable — 716px height)**
- Container Padding: 16px horizontal
- Vertical Spacing: 24px between sections

**Section 1: Payment Method Selector (120px height)**
- Label: "Méthode de Paiement" — 14px, weight 600
- **Horizontal Icon Grid (4 columns)**
  - Each Option: 80px × 80px
  - Layout: Icon (40px) + Label (12px)
  - Options:
    1. Wafacash (logo)
    2. CashPlus (logo)
    3. Bank Transfer (icon)
    4. Driver Cash (icon)
  - Selected: Border 2px solid `#4F46E5`, background `#EEF2FF`
  - Unselected: Border 1px solid `#E2E8F0`, background `#FFFFFF`

**Section 2: Receipt Scanner (280px height)**
- **Large Camera Button:**
  - Size: 260px × 200px
  - Background: `#F8FAFC`
  - Border: 2px dashed `#94A3B8`
  - Corner Radius: 16px
  - Icon: Camera (48px, color `#4F46E5`)
  - Label: "Prendre une photo du reçu" / "صور الورقة"
  - Font: 16px, weight 600, color `#64748B`

- **Camera Overlay (when active):**
  - Show transparent guide box for receipt alignment
  - Instruction: "Align reference number in center"

**Section 3: Manual Data Entry (160px height)**
- **Field 1: Reference Number**
  - Label: "Code de transaction" / "الرقم السري"
  - Input: Numeric keyboard
  - Height: 56px
  - Background: `#FFFFFF`
  - Border: 1px solid `#E2E8F0`
  - Corner Radius: 12px

- **Field 2: Amount Paid**
  - Label: "Montant versé (DH)" / "شحال صيفطتي"
  - Input: Decimal keyboard, max 2 decimals
  - Height: 56px
  - Placeholder: "0.00 DH"
  - Font: 18px, weight 600

- Vertical Gap: 16px between fields

**Section 4: Safety Note (40px height)**
- Text: "Le solde sera mis à jour après validation du fournisseur"
- Font: 12px, weight 400, color `#64748B`
- Icon: Info (16px, color `#4F46E5`)

**Bottom Navigation Bar (64px height)**
- **Primary Button:**
  - Text: "Envoyer au Grossiste" / "صيفط لمول السلعة"
  - Height: 56px
  - Background: `#10B981` (Emerald Green)
  - Text Color: `#FFFFFF`
  - Font: 16px, weight 700
  - Corner Radius: 14px
  - Width: 358px (full width minus margins)

**Total Screen Height Breakdown:**
- Header: 64px
- Body: 716px (scrollable)
- Bottom Button: 64px
- **Total: 844px ✓**

---

### Screen E: Driver Logistics (The "Route Ticket")

**Purpose:** Text-based delivery job card with bidding and PIN handshake.

#### Layout Specification

**Constraint:** NO MAPS — Text-based navigation only (for offline reliability).

**Header (Static — 64px height)**
- Title: "Livraisons Disponibles" / "الطلبات الجديدة"
- Font: 18px, weight 700, color `#1E293B`
- Background: `#F8FAFC`

**Body (Scrollable — 716px height)**
- **Job Card Design (Physical Ticket Style)**
  - Height: ~280px per card
  - Background: `#FFFFFF`
  - Border: 2px solid `#4F46E5`
  - Corner Radius: 16px
  - Shadow: 0 4px 12px rgba(79, 70, 229, 0.15)
  - Padding: 20px
  - Vertical Gap: 16px between cards

**Delivery Job Card Anatomy:**
```
┌──────────────────────────────────────────┐
│ Job #4721                    [COD Badge] │ ← Header
│ ──────────────────────────────────────── │
│                                          │
│ DE (From):                               │
│ 📍 Grossiste Alami                       │ ← Supplier
│    Derb Omar, Casablanca                 │    Business name + location
│    (Near Mosque Hassan II)               │    Landmark hint
│                                          │
│ VERS (To):                               │
│ 📍 Teleboutique Youssef                  │ ← Retailer
│    Hay Hassani, Casablanca               │    Shop name + location
│    (Rue 12, Building 5)                  │    Landmark hint
│                                          │
│ CARGO:                                   │
│ 📦 2 Boxes (Small)                       │ ← Package info
│                                          │
│ ──────────────────────────────────────── │
│                                          │
│ [State 1: Bidding]                       │
│ ┌─────────────────────┐                 │
│ │ Votre prix: ___ DH │   [Proposer]    │ ← Bid input + button
│ └─────────────────────┘                 │
│                                          │
│ OR                                       │
│                                          │
│ [State 2: Active Trip]                   │
│        PIN Code: 4921                    │ ← Large, centered
│        (Show to Retailer)                │    32px, weight 800
│                                          │
│ [Marquer comme Livré]                   │ ← Complete button
└──────────────────────────────────────────┘
```

**COD Badge (if applicable):**
- Position: Top-right corner
- Text: "COD: 1,200 DH"
- Background: `#FEE2E2`
- Text Color: `#991B1B`
- Font: 12px, weight 700
- Padding: 6px 12px
- Corner Radius: 8px

**Bid Input Section (State 1):**
- Input Field:
  - Width: 180px
  - Height: 48px
  - Background: `#F8FAFC`
  - Border: 1px solid `#E2E8F0`
  - Placeholder: "Ex: 50.00"
  - Font: 16px, weight 600

- Button:
  - Text: "Proposer" / "بيض"
  - Width: 140px
  - Height: 48px
  - Background: `#4F46E5`
  - Text Color: `#FFFFFF`
  - Corner Radius: 12px

**Active Trip Section (State 2):**
- **PIN Display:**
  - Font: 48px (extremely large for visibility)
  - Weight: 800
  - Color: `#4F46E5`
  - Background: `#EEF2FF`
  - Padding: 24px
  - Corner Radius: 16px
  - Text-align: center

- **Instruction Text:**
  - "Show this code to Retailer upon arrival"
  - Font: 14px, weight 500, color `#64748B`
  - Text-align: center
  - Margin-top: 12px

- **Complete Button:**
  - Text: "Marquer comme Livré" / "سلمت"
  - Height: 56px
  - Background: `#10B981`
  - Text Color: `#FFFFFF`
  - Font: 16px, weight 700
  - Full-width
  - Disabled until PIN verified

**Location Name Formatting:**
- **Line 1:** Business Name — 16px, weight 700, color `#1E293B`
- **Line 2:** City/Area — 14px, weight 500, color `#64748B`
- **Line 3:** Landmark/Street — 14px, weight 400, color `#94A3B8`, italic

**Bottom Navigation Bar (64px height)**
- 2 Tabs: Available Jobs | Active Trips
- Selected Color: `#4F46E5`
- Unselected Color: `#94A3B8`

**Total Screen Height Breakdown:**
- Header: 64px
- Body: 716px (scrollable)
- Bottom Nav: 64px
- **Total: 844px ✓**

---

## 3. Responsive Behavior Within Fixed Frame

### Scrollable Areas
All screens use **internal scrolling** rather than full-page scroll:
- Header: Fixed (no scroll)
- Body: Vertical scroll only (momentum scrolling)
- Footer/Bottom Bar: Fixed (no scroll)

### Scroll Indicators
- Show iOS-style scroll indicator on right edge (2px width, `#94A3B8`, 30% opacity)
- Auto-hide after 1 second of inactivity
- Bounce effect at scroll limits (iOS standard)

### Loading States
- Use skeleton screens (not spinners) for initial load
- Skeleton matches card dimensions (e.g., 173×180 for supplier cards)
- Skeleton color: `#E2E8F0` with shimmer animation

### Empty States
- Show centered icon (80px) + message (16px) + action button
- Icon color: `#94A3B8`
- Message: "Aucun produit trouvé" / "ماكاينش حتى حاجة"
- Action: "Réinitialiser les filtres"

---

## 4. Interaction Patterns

### Button States
| State | Background | Text | Border | Opacity |
|-------|------------|------|--------|---------|
| Default | `#4F46E5` | `#FFFFFF` | None | 100% |
| Hover | `#4338CA` | `#FFFFFF` | None | 100% |
| Active/Pressed | `#3730A3` | `#FFFFFF` | None | 100% |
| Disabled | `#E2E8F0` | `#94A3B8` | None | 60% |

### Haptic Feedback
- Light tap: Add to cart, increment/decrement
- Medium tap: Primary button press (Confirm, Send)
- Error vibration: Over-limit warning, invalid input
- Success vibration: Order confirmed, payment sent

### Transitions
- Page transitions: 300ms ease-in-out slide
- Modal appearance: 250ms ease-out scale + fade
- Card expansion: 200ms ease-out
- Stepper changes: 150ms ease (no animation on value)

---

## 5. Accessibility

### Touch Targets
- Minimum: 48px × 48px (WCAG AAA)
- Spacing between targets: 8px minimum

### Color Contrast
- Text on background: 4.5:1 minimum (WCAG AA)
- Primary button text: 7:1 (WCAG AAA)
- Debt amount (red on white): 6.2:1 ✓
- Credit amount (green on white): 4.8:1 ✓

### Typography
- Minimum font size: 14px (except labels at 12px)
- Line height: 1.5× font size minimum
- Letter spacing: Default (no negative tracking)

### Localization Support
- RTL support for Arabic (Darija uses RTL layout)
- Number formatting: Western Arabic numerals (1, 2, 3)
- Currency: "DH" suffix (not prefix)
- Date: DD/MM/YYYY format

---

## 6. Design Tokens Reference

### Spacing Scale (8px base)
```
xs:   4px
sm:   8px
md:  16px
lg:  24px
xl:  32px
xxl: 48px
```

### Border Radius Scale
```
sm:   8px  (badges, chips)
md:  12px  (input fields, small cards)
lg:  16px  (main cards, modals)
xl:  24px  (hero elements)
```

### Shadow Scale
```
sm: 0 1px 2px rgba(0, 0, 0, 0.05)
md: 0 4px 6px rgba(0, 0, 0, 0.07)
lg: 0 10px 15px rgba(0, 0, 0, 0.10)
xl: 0 20px 25px rgba(0, 0, 0, 0.15)
```

---

## 7. Implementation Notes

### Flutter Widget Mapping
- **Screen Container:** `SafeArea` + `Scaffold`
- **Scrollable Body:** `CustomScrollView` with `SliverList`
- **Sticky Footer:** `Positioned` widget in `Stack` or dedicated footer slot in `Scaffold`
- **Product Cards:** `Card` with `InkWell` for tap effects
- **Steppers:** Custom widget with `IconButton` (-, +) and `Text` (value)
- **Filter Chips:** `Wrap` with `ChoiceChip` widgets

### Performance Targets
- 60fps scroll performance (no jank)
- Image lazy loading (load only visible cards + 2 ahead)
- Debounce search input (300ms)
- Cache product images (max 50MB)

### Offline Considerations
- Show cached data immediately
- Display "Offline" banner (yellow, 40px height) below header
- Queue actions (add to cart, bid) when offline
- Sync when connection restored

---

## 8. Color Scheme Migration

### Current vs. New Colors

**Colors to Update:**
| Component | Current | New | Reason |
|-----------|---------|-----|--------|
| Primary Brand | `#C2410C` (Orange) | `#4F46E5` (Deep Indigo) | Trust & Business identity |
| Success/Money | `#10B981` (Green) | ✓ Keep | Already correct |
| Error/Debt | `#EF4444` (Red) | `#E11D48` (Rose Red) | More vibrant for debt visibility |
| Background | `#FAF9F7` (Warm) | `#F8FAFC` (Cool Slate) | Low glare, professional |
| Surface Cards | `#E7E5E4` (Warm) | `#FFFFFF` (White) | Clean, modern |
| Borders | `#D6D3D1` (Warm) | `#E2E8F0` (Cool) | Subtle, professional |

### Files to Update
1. `/app/lib/core/theme/app_colors.dart` — Update color constants
2. `/app/lib/core/theme/app_theme.dart` — Update ThemeData references
3. All screen files — Replace hardcoded color references

---

## 9. Typography Updates

### Current vs. New

**Fonts:**
- Current: Manrope (headings) + Inter (body) ✓ Keep
- Minimum body size: Increase from 14px → 16px for outdoor readability

**Font Weights to Emphasize:**
- Headlines: 800 (extra bold) for maximum visibility
- Body: 400 (regular) for comfortable reading
- Buttons: 700 (bold) for clear CTAs

---

## 10. Validation Checklist

Before marking this design system complete, verify:

- [ ] All screens fit within 390×844 viewport
- [ ] No full-page scroll (only body sections scroll)
- [ ] All touch targets ≥ 48px
- [ ] All text ≥ 16px (except 12px labels)
- [ ] Color contrast ratios pass WCAG AA
- [ ] Primary color is Deep Indigo (`#4F46E5`)
- [ ] Success color is Emerald Green (`#10B981`)
- [ ] Debt color is Rose Red (`#E11D48`)
- [ ] Background is Slate Gray (`#F8FAFC`)
- [ ] All French/Darija labels are present
- [ ] Sticky footers work on all screens
- [ ] Loading states use skeletons (not spinners)
- [ ] Offline mode displays cached data

---

**Document Version:** 1.0  
**Last Updated:** 2026-02-17  
**Status:** Complete — Ready for Implementation
