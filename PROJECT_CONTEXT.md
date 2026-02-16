This is the finalized Project Context & System Prompt. You should save this as a file named PROJECT_CONTEXT.md. This version includes the "Rolling Debt" logic, the bilingual "Handshake" delivery, the "Partial Receipt" feature, and the "Compatibility-First" product discovery.
PROJECT CONTEXT: Morocco B2B Phone Accessory Ledger
1. VISION & CORE LOGIC

A high-utility B2B marketplace for the Moroccan phone accessory ecosystem (Derb Ghallef, Garage Allal style).

    The "Carnet" (Rolling Debt) System: Transactions are rarely settled to zero. It is a continuous cycle of ordering goods on credit and making partial payments.

    The Handshake Delivery: Uses independent, trusted community drivers (Livreurs/Kourtia). The app digitizes the trust, not the logistics company.

    Utility over Decoration: Every feature must mirror the real-world workflow of a Moroccan Moul Hanout.

2. USER ROLES

    Supplier (Admin): Manages inventory, sets tiered pricing, approves/adds retailers, and sets credit limits.

    Retailer (Buyer): Browses by phone model compatibility, tracks their "Running Tab," and confirms deliveries.

    Driver (Hybrid User):

    Trusted Staff: Assigned manually by Supplier. Uses WhatsApp for confirmation.

    Freelance (InDrive Model): Uses the App to view "Open Jobs" and place bids.

3. FEATURE SPECIFICATIONS (Agreed Logic)
A. Product Discovery & Listing

    Tiered Pricing: 3 levels (e.g., 1-10 pcs, 11-50 pcs, 50+ pcs). Prices in Cart must update dynamically.

    Compatibility Filter: Retailers search by Phone Brand -> Model (e.g., Samsung -> A54) rather than just product names.

    "Nouveau" (جديد) Tag: Suppliers can toggle a "New Arrival" status to push items to the top of the feed.

B. The "Digital Bon" & Handshake

    Order Creation: Supplier assigns a driver name to an order.

    Partial Receipt (Critical): Retailers can adjust the quantity of received items at the moment of delivery (to account for cracked screens/missing items) before the final "Confirm" button increases their debt.

    Digital Signature: Replacing the physical stamp with a "Confirm Receipt" button that triggers a timestamped PDF/Image sent to WhatsApp.

C. The Money Engine (The Ledger)

    Current Balance: Total Value of Confirmed Bons - Total Value of Confirmed Payments.

    Manual Payment Entry: Only the Supplier/Admin records payments (cash brought back by drivers) to ensure the "Ledger" remains the source of truth.

    Voice Notes: Integrated WhatsApp button on every order page for Darija-based communication.

4. TECH STACK & UI RULES

    Frontend: "Flutter (Offline-first using supabase_flutter with pkce auth and local data caching enabled)." This ensures the app works in the basement of a Souk.

    Backend: Supabase (PostgreSQL for relational ledger integrity).

    Localization: Hybrid French + Moroccan Darija (Arabic Script).

        French: Professional structure (e.g., "Solde Actuel").

        Darija: Direct action/status (e.g., "وصلاتني السلعة").

    UX: Large grid views, high-contrast text, big buttons (no keyboard entry where a "+" button works).

5. DATABASE SCHEMA HINTS (For Copilot)

    profiles: includes credit_limit and current_balance.

    products: includes compatibility_list (array of phone models) and price_tiers (JSONB).

    ledger: every row is a transaction linked to a profile_id.

    orders: includes driver_name and adjusted_total (for partial receipts).

6. DEVELOPMENT GUIDELINES

    Currency: Format as X.XX DH.

    Date: Use DD/MM/YYYY.

    Communication: Use the WhatsApp Business API or url_launcher for WhatsApp deep links.

    Security: No public sign-up. Retailers are created by the Supplier.

    9. TECHNICAL IMPLEMENTATION DEEP-DIVE (DATABASE & LOGIC)
A. Relational Debt Logic

    Balance Context: Debt is NOT global. It is stored in supplier_retailer_relations. One Retailer can have multiple balances across different Suppliers.

    Trigger Logic: The current_balance must only update when a ledger_transaction status changes to verified.

        order_increase -> Adds to balance (Retailer owes more).

        payment_decrease -> Subtracts from balance (Retailer paid off debt).

B. Tiered Pricing JSONB Structure

    Products use a JSONB field price_tiers.

    Format: {"1": 15.0, "10": 12.0, "50": 10.0}.

    Logic: The app must look for the highest key that is ≤ the current cart quantity.

C. Logistics & Bidding Table Relationships

    orders link to delivery_jobs.

    delivery_jobs host multiple delivery_bids.

    A delivery_job can be "Delivery Only" or "COD (Cash Collection)".

10. STEP-BY-STEP MVP DEVELOPMENT PROMPT

Use these specific prompts with Copilot to build the features in order:
Step 1: Database Setup (The Brain)

    "Based on the PROJECT_CONTEXT.md, generate the SQL migration for Supabase. Include the profiles, supplier_retailer_relations, products, orders, and ledger_transactions tables. Most importantly, write the PostgreSQL Trigger Function that updates the current_balance in supplier_retailer_relations only when a transaction is marked as 'verified'."

Step 2: The Multi-Supplier Dashboard (Retailer UI)

    "Build a Flutter screen for the Retailer Dashboard. It must fetch all rows from supplier_retailer_relations for the logged-in user. Display each supplier as a card showing:

        Business Name.

        Current Debt (Solde) in DH.

        A 'Pay' button (opens Wafacash upload) and a 'Buy' button (opens that supplier's catalog)."

        Include an 'Add New Supplier' button that opens a WhatsApp deep link to invite a contact to the platform."

Step 3: Product Filtering by Compatibility

    "Create a Flutter GridView for the product catalog... [Existing text]...
Crucial Addition: Add a 'Microphone' icon in the search bar. When held, use the speech_to_text package to capture Darija/French product names (e.g., 'Cable Type C') and auto-fill the text search field."

Step 4: The Bidding Logic (Livreur UI)

    "Design a screen for the Driver role. It should list all delivery_jobs where status is 'open'. For each job, show the pickup/dropoff city and a 'Bid' button. When the driver bids, create a record in delivery_bids. The Supplier must be able to see these bids and click 'Accept', which updates the job status to 'bidding_closed'."


To make the app feel "at home," we will use French for the formal structure and Moroccan Darija (written in Arabic script) for the actions. This combination is common in Morocco because it feels professional yet accessible.

Here is the JSON map. You can save this as l10n_map.json and give it to Copilot to generate your Flutter .arb files or your localization class.
The Bilingual "Souk" Map
JSON

{
  "app_title": {
    "fr": "L'Carnet B2B",
    "ar_MA": "لكارني B2B"
  },
  "dashboard": {
    "current_debt": {
      "fr": "Solde Actuel",
      "ar_MA": "الحساب لي عليك"
    },
    "credit_limit": {
      "fr": "Limite de Crédit",
      "ar_MA": "بلافو ديالك"
    },
    "my_suppliers": {
      "fr": "Mes Grossistes",
      "ar_MA": "المالين السلعة ديالي"
    }
  },
  "catalog": {
    "search_compatibility": {
      "fr": "Filtrer par modèle (ex: iPhone 13)",
      "ar_MA": "قلب بالموديل (مثلا ايفون 13)"
    },
    "new_arrival": {
      "fr": "Nouveauté",
      "ar_MA": "جديد"
    },
    "wholesale_price": {
      "fr": "Prix de Gros",
      "ar_MA": "ثمن الجملة"
    }
  },
  "actions": {
    "confirm_order": {
      "fr": "Valider la Commande",
      "ar_MA": "كونفطرمي الطلبية"
    },
    "confirm_receipt": {
      "fr": "J'ai reçu la marchandise",
      "ar_MA": "وصلاتني السلعة"
    },
    "declare_payment": {
      "fr": "Déclarer un Paiement",
      "ar_MA": "خلصت شوية"
    },
    "upload_receipt": {
      "fr": "Photo du reçu (Wafacash/CashPlus)",
      "ar_MA": "صور الورقة ديال كاش بلوس"
    }
  },
  "logistics": {
    "find_driver": {
      "fr": "Chercher un livreur",
      "ar_MA": "قلب على كورتي"
    },
    "bid_amount": {
      "fr": "Votre prix de livraison",
      "ar_MA": "ثمن الخدمة ديالك"
    },
    "cash_collection": {
      "fr": "Avec collecte d'argent",
      "ar_MA": "فيها جمع الفلوس"
    }
  },
  "status": {
    "pending": {
      "fr": "En préparation",
      "ar_MA": "كتوجد"
    },
    "shipped": {
      "fr": "En route",
      "ar_MA": "في الطريق"
    },
    "delivered": {
      "fr": "Livré",
      "ar_MA": "وصلات"
    },
    "verified": {
      "fr": "Validé",
      "ar_MA": "مقبولة"
    }
  }
}

💡 Pro-Tips for Using this Map in Morocco:

    Numbers & Currency:
    Even in the Arabic version, keep the numbers as 1, 2, 3 (Western Arabic) and use "DH" or "د.م". Most retailers in the accessory business prefer "DH" as it's what they see on their traditional paper Bons.

    Voice Note Tooltip:
    Add a Darija label for the WhatsApp button: "صيفط أوديو" (Send Audio). Since many retailers prefer speaking to typing, this button should be prominent.

    The "Confirmed" Stamp:
    When a payment is verified, show a badge that says "Khalassa Safia" (خالصة صافية). It’s a very common phrase in the Moroccan market meaning "Paid in full/Settled."

    Step 5: The Supplier Admin Portal (Web/Tablet)

    "Create a Dashboard for the Supplier (Admin). It needs three key tabs:

        Inventory (Quick Add): A tabular view to add products rapidly. Inputs: Name, Price tiers (JSON), and Image.

        Ledger Verification: A list of ledger_transactions where status is 'pending'. Show the 'Evidence Photo' (Wafacash receipt) side-by-side with 'Approve/Reject' buttons. Clicking 'Approve' must trigger the Database Update function.

        Delivery Dispatch: A view of 'Ready Orders'. Allow the Supplier to either 'Assign Trusted Driver' (Select from list) or 'Post to Marketplace' (Opens bidding)."

Feature: Intelligent Bulk Price Adjustment

    Logic: Suppliers must be able to adjust prices across multiple products simultaneously without setting them to a single flat rate.

    Adjustment Modes:

        Fixed Offset: Add or subtract a specific amount (e.g., +10 DH) to the current price of all selected items.

        Percentage Shift: Increase or decrease prices by a percentage (e.g., +5%) to account for currency or shipping fluctuations.

        Flat Override: Set a specific price for all selected items (used for identical-tier goods).

    Tiered Pricing Impact: Bulk updates should apply to the "Level 1" price, and the system should ask if it should auto-calculate Level 2 and Level 3 prices based on the same percentage/offset.

    Safety Rule: A "Preview Change" step is mandatory. The UI must show "Old Price" vs. "New Price" for at least 3 sample items before the supplier confirms the bulk update to prevent catastrophic data errors.

    
    1. UI Layout: The "Declaration" Screen
Header (French/Darija)

    Title: Déclarer un Paiement / خلصت شوية

    Context: "Relationship: [Supplier Name] | Balance Due: 2,500 DH"

Step 1: Selection of Service (Icon Grid)

Instead of a dropdown, use a horizontal scroll of logos (Wafacash, CashPlus, Bank Transfer, Driver Cash).

    Why: It’s faster to tap a logo than to read a list.

Step 2: The "Receipt Scanner" (The Core Action)

A large, square button with a camera icon.

    Label: Prendre une photo du reçu / صور الورقة

    Logic: When clicked, it opens the camera.

    UI Overlay: Show a transparent "Guide Box" on the camera screen to help the user align the receipt so the Reference Number is visible.

Step 3: Manual Data Entry (Safety Net)

Below the photo, add two manual fields (since AI/OCR might fail on blurry thermal paper):

    Reference Number: Code de transaction / الرقم السري (Numerical keyboard).

    Amount Paid: Montant versé / شحال صيفطتي (DH).

Step 4: Final Confirmation

A big Green Button at the bottom.

    Label: Envoyer au Grossiste / صيفط لمول السلعة

    Safety: A small note below the button: "Le solde sera mis à jour après validation du fournisseur" (The balance will update after supplier validation).

2. The Backend "Trust" Logic

When the user hits "Send":

    A new record is created in ledger_transactions with status: 'pending'.

    The current_balance does not change yet.

    The Supplier receives a Push Notification and a WhatsApp message: "Retailer [Shop Name] has declared a payment of [Amount] DH. Click here to verify."

3. Implementation Prompt for Copilot

Copy/Paste this into your workflow:

    "Build a Flutter 'Payment Declaration' screen based on the PROJECT_CONTEXT.md.

        Include a ImagePicker for the user to photograph their Wafacash/CashPlus receipt.

        Create a form with two controllers: amount (Decimal) and referenceCode (String).

        Use the l10n_map.json for all labels (Bilingual).

        When submitted, create a record in the ledger_transactions table in Supabase. The status must be set to 'pending'.

        After successful submission, show a 'Success' animation and a button to 'Open WhatsApp to notify Supplier' which pre-fills a message with the Reference Code and Amount."

4. Why this handles the "Standard" Receipt Issue

Even though Wafacash and CashPlus look slightly different, your app focuses on the two common truths:

    The Photo (Visual proof for the supplier to check later).

    The Reference Code (The unique ID the supplier uses to withdraw the cash).

By asking for the photo AND the code, you eliminate 99% of "I made a mistake" or "I lied about the payment" issues.