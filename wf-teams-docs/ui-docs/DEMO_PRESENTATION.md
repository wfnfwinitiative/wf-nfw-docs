# 🍱 No Food Waste Platform — NGO Business Demo Guide
**Date:** March 16, 2026 | **Audience:** NGO Business Team

---

## 🗺️ Platform Overview — Who Does What

```
┌─────────────────────────────────────────────────────────────────┐
│                        PLATFORM ROLES                           │
├──────────────┬──────────────────┬─────────────┬────────────────┤
│  SUPER ADMIN │      ADMIN       │ COORDINATOR  │    DRIVER      │
│              │                  │              │                │
│ Creates      │ Manages all      │ Creates &    │ Receives tasks │
│ Admin users  │ users, donors,   │ assigns food │ on mobile,     │
│              │ hunger spots,    │ pickup       │ navigates,     │
│              │ vehicles &       │ opportunities│ collects food, │
│              │ feature flags    │ & reviews    │ submits proof  │
└──────────────┴──────────────────┴─────────────┴────────────────┘
```

---

## 🔄 End-to-End Flow Diagram

```
[SUPER ADMIN]
     │
     ▼
Creates ADMIN account
     │
     ▼
[ADMIN] logs in
     │
     ├──► Add Coordinators (name, phone, email, password)
     │
     ├──► Add Drivers (name, phone, email, password)
     │
     ├──► Add Vehicles (vehicle number, type)
     │
     ├──► Register Donors (food source — hotels, events, caterers)
     │
     ├──► Register Hunger Spots (orphanages, shelters, communities)
     │
     └──► Control Feature Flags (Voice AI, Google Drive upload)
                │
                ▼
         [COORDINATOR] logs in
                │
                ├──► Dashboard → sees quick actions
                │
                ├──► Create Opportunity
                │       Select: Donor → Hunger Spot → Driver → Vehicle
                │       Set: Pickup ETA, Delivery Deadline, Feeding Count, Notes
                │
                └──► Review Opportunities
                        View all created opportunities
                        Edit & reassign if needed
                        Track status of each opportunity
                              │
                              ▼
                        [DRIVER] receives task on mobile app
                              │
                              ├──► Dashboard → filter by status
                              │       (All / Assigned / In Progress / Done)
                              │
                              ├──► Tap assignment card
                              │       See: Donor info, contact, ETA
                              │       See: Hunger Spot, delivery deadline
                              │       See: Vehicle assigned
                              │
                              ├──► 📍 Navigate (live GPS → opens Google Maps)
                              │       • Navigate to Pickup location
                              │       • Navigate to Drop location
                              │
                              ├──► "Fill Pickup Details" (status: Assigned)
                              │       🎙️ Voice Input → speak food items
                              │           AI transcribes → structured list
                              │       📸 Upload pickup photos
                              │           Camera OR Gallery
                              │           → uploads to Google Drive folder
                              │       Submit → status moves to "InPicked"
                              │
                              └──► "Confirm Delivery" (status: InPicked)
                                      📸 Upload delivery proof photos
                                      Submit → status moves to "Delivered"
                                      Coordinator is notified for review
```

---

## 🎯 Demo Script — Screen by Screen

---

### 1️⃣ LOGIN SCREEN
**URL:** `/login`

**Show:**
- Clean branded login page with NGO's food imagery
- Stats on the hero: 2,450+ kg saved, 45+ Hunger Spots, 156+ Deliveries
- Mobile-friendly responsive layout
- Secure authentication

**Key Point:** _"Role-based access — same login for all users, system detects the role and routes to the right dashboard."_

---

### 2️⃣ ADMIN DASHBOARD
**URL:** `/admin/dashboard`

**Show:**
- Live stats cards: Total Coordinators, Drivers, Vehicles, Donors, Hunger Spots
- Charts: Opportunities over time (bar/line chart)
- Date range filter (7d / 30d / 90d)

**Key Point:** _"Admin gets a bird's eye view of the entire operation in real time."_

---

### 3️⃣ ADMIN → COORDINATORS
**URL:** `/admin/coordinators`

**Show:**
- List of all coordinators with contact details
- Click **"Add Coordinator"** → fill name, phone, email, password
- Form validation (required fields, email format)
- Coordinator is immediately active and can log in

**Key Point:** _"Admin can onboard a new coordinator in under 30 seconds. No IT involvement needed."_

---

### 4️⃣ ADMIN → DRIVERS
**URL:** `/admin/drivers`

**Show:**
- List of all drivers
- Add new driver with credentials
- Edit existing driver info

---

### 5️⃣ ADMIN → VEHICLES
**URL:** `/admin/vehicles`

**Show:**
- Fleet management — all registered vehicles
- Add vehicle (number, type)
- Vehicles appear in the opportunity assignment dropdown

---

### 6️⃣ ADMIN → DONORS
**URL:** `/admin/pickup-locations`

**Show:**
- All registered food donors (hotels, caterers, event venues, etc.)
- Add donor: name, city, pincode, contact person, mobile, address
- These feed into the coordinator's "Create Opportunity" dropdown

**Key Point:** _"Once a donor is registered, coordinators can create pickups from them instantly."_

---

### 7️⃣ ADMIN → HUNGER SPOTS
**URL:** `/admin/hungerspots`

**Show:**
- All registered delivery destinations (orphanages, shelters, community kitchens)
- Add hunger spot: name, location, contact, capacity
- These appear in the delivery assignment dropdown

---

### 8️⃣ ADMIN → FEATURE FLAGS  ⭐ Unique Feature
**URL:** `/admin/feature-flag`

**Show:**
- Toggle **Voice AI Support** ON/OFF — enables AI voice transcription for drivers
- Toggle **Google Drive Image Upload** ON/OFF — enables photo proof upload
- Changes take effect immediately across all user sessions

**Key Point:** _"Admin can roll out new features gradually — for example, turn on Voice AI for a pilot group first before enabling it for all drivers."_

---

### 9️⃣ COORDINATOR DASHBOARD
**URL:** `/coordinator/dashboard`

**Show:**
- Quick action tiles: "Create Opportunity", "Review Opportunities"
- Clean and focused — coordinators see only what they need

---

### 🔟 COORDINATOR → CREATE OPPORTUNITY  ⭐ Core Feature
**URL:** `/coordinator/create-opportunity`

**Show:**
- Dropdown: Select **Donor** (the food source)
- Dropdown: Select **Hunger Spot** (the delivery destination)
- Dropdown: Select **Driver** (who will do the pickup)
- Dropdown: Select **Vehicle** (assigned transport)
- Set **Pickup ETA** — date and time
- Set **Delivery By** deadline
- Set **Feeding Count** — how many people will be fed
- Add **Notes** for the driver
- Submit → opportunity is created and driver is notified instantly

**Key Point:** _"This entire end-to-end assignment, from food source to hungry person, takes under 2 minutes."_

---

### 1️⃣1️⃣ COORDINATOR → REVIEW OPPORTUNITIES
**URL:** `/coordinator/review-opportunities`

**Show:**
- All opportunities listed with their live status
- Filter by status: Assigned / InPicked / Delivered / Verified / Completed
- Click any opportunity → see full details → edit / reassign

**Key Point:** _"Coordinators can track every active opportunity in real time without calling drivers."_

---

### 1️⃣2️⃣ DRIVER DASHBOARD (Mobile View)  ⭐ Show on Phone
**URL:** `/driver/dashboard`

**Show:**
- **Bottom tab navigation** — native mobile app feel (Dashboard / My Tasks)
- Filter cards: All / Assigned / In Progress / Completed
- Assignment cards showing:
  - Donor name & contact
  - Pickup address + **📍 Navigate icon** → opens Google Maps app
  - Hunger spot & delivery address + **📍 Navigate icon**
  - Vehicle number
  - Pickup ETA and Delivery deadline
  - Status badge

**Key Point:** _"Drivers never need to call the coordinator for directions — one tap opens navigation on their phone."_

---

### 1️⃣3️⃣ DRIVER → FILL PICKUP DETAILS  ⭐ Wow Feature
**Status:** Assigned → opens PickupDetailModal

**Show:**

**🎙️ Voice AI Input (if feature flag is ON):**
- Driver taps mic → speaks the food items in natural language
  > _"I have 50 rice packets, 30 sambar portions and 20 chapati packs"_
- AI transcribes and structures it into a food items list automatically
- Driver can edit/correct individual items

**📸 Photo Upload:**
- Tap "Add" → choose Camera or Gallery (both options)
- Photos upload to Google Drive automatically on submit
- Real-time upload progress bar per image

**Submit:**
- Status moves from **Assigned → InPicked**
- Data saved to database
- Coordinator sees updated status in real time

**Key Point:** _"Drivers don't need to type anything. They just speak. The AI does the rest."_

---

### 1️⃣4️⃣ DRIVER → CONFIRM DELIVERY
**Status:** InPicked → Confirm Delivery

**Show:**
- Driver adds delivery proof photos (food being served)
- Photos uploaded to a separate Google Drive folder
- Submit → status moves to **Delivered**
- Coordinator can now verify

---

## ✅ Status Lifecycle Summary

```
ASSIGNED → (driver fills pickup details) → INPICKED
         → (driver confirms delivery)   → DELIVERED
         → (coordinator verifies)       → VERIFIED
         → (auto/manual close)          → COMPLETED

         (if issue)                     → REJECTED
```

---

## 🌟 Key Value Features — Highlight These

| Feature | What it does | Value to NGO |
|---|---|---|
| 🎙️ **Voice AI** | Driver speaks, AI transcribes food items | No typing for drivers — faster, error-free |
| 📍 **GPS Navigation** | One tap → opens Google Maps with live route | No phone calls for directions |
| 📸 **Photo Proof** | Camera + gallery upload to Google Drive | Audit trail for every delivery |
| 🚩 **Feature Flags** | Admin toggles features ON/OFF live | Roll out features safely, no redeployment |
| 📊 **Real-time Dashboard** | Live stats and charts | Management visibility at all times |
| 📱 **Mobile Bottom Nav** | Native app-like navigation | Drivers feel comfortable — no learning curve |
| 🔐 **Role-based Access** | 4 separate dashboards from one login | Secure, clean experience per user type |
| 🌙 **Dark Mode** | Full dark theme supported | Comfortable for night-time drivers |

---

## 🔜 Coming Soon (Mention at End)

- ✅ Footer on all screens *(just added)*
- 🔜 Coordinator screen polish & verification flow
- 🔜 Lat/Long based precision navigation (backend team adding coordinates)
- 🔜 Push notifications for drivers when assigned
- 🔜 Admin analytics — kg saved per month, deliveries by area
- 🔜 Donor & Hunger Spot self-registration portal

---

## 📌 Demo Tips

1. **Use mobile phone or browser DevTools mobile view** for driver demo — the bottom nav looks great
2. **Pre-create one opportunity** before the demo so you can show the driver flow live without waiting
3. **Show Feature Flag toggle live** — turn voice ON during the demo for instant wow factor
4. **Show the Google Maps navigation** — tap the map icon on a card, it opens Maps — works on any phone
5. **Keep login credentials ready** — have admin, coordinator, and driver logins open in different browser tabs

---

_Built by the WF-NFW Tech Team | Platform Version 1.0_
