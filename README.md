# Bus & Passenger Management – Salesforce Project

## 1. Overview
This Salesforce solution manages buses, passengers, and bus companies.  
It ensures that bus capacity rules are enforced and provides visibility into buses and their passengers via a Lightning Web Component (LWC).

The project includes:
- **Custom Objects:** `Bus__c`, `Passenger__c`, `Bus_Company__c`
- **Business Logic:** Apex Batch (`BusStatusUpdateBatch`)
- **User Interface:** LWC (`busCompanyBuses`)
- **Testing:** Apex test classes with full coverage

---

## 2. Data Model

### Objects and Relationships

**Bus__c**
- **Fields:**
  - `Bus_Status__c` (Picklist: Available, Limited Seats, Full)
  - `Passenger_Count__c` (Roll-Up Summary: counts related passengers)
- **Relationships:**
  - Lookup → `Bus_Company__c`

**Passenger__c**
- **Fields:**
  - `Name`
- **Relationships:**
  - Lookup → `Bus__c`

**Bus_Company__c**
- **Fields:**
  - `Name`
- **Relationships:**
  - Parent for `Bus__c`

**Constraint:**  
One bus may have up to 20 passengers.

---

## 3. Business Logic

**Batch Class: `BusStatusUpdateBatch`**
- **Implements:** `Database.Batchable<Id>`, `Database.Stateful`
- **Constructor:** Accepts `List<Id>` of bus IDs
- **Logic:**
  - `<10` passengers → **Available**
  - `11–19` passengers → **Limited Seats**
  - `20` passengers → **Full**
  - `>20` passengers → Throws `PassengersException`, skips update for that bus

**Key Points:**
- Uses `Database.update(..., false)` for partial success
- Handles empty scope safely with early return
- Continues processing after exceptions

---

## 4. User Interface

**LWC: `busCompanyBuses`**
- **Purpose:** Display buses and their passengers for a given Bus Company
- **Inputs:** `@api recordId` (Bus Company ID)
- **Features:**
  - Uses `@wire` with `BusCompanyActions.getBusesWithPassengers`
  - Shows bus name, status, and passenger list
  - Displays SLDS spinner while loading
  - Error message handling (`busesError`)
  - No data message (`showNoBuses`)

**Apex Controller: `BusCompanyActions`**
- **Method:** `getBusesWithPassengers(Id busCompanyId)`
- Returns all buses (and related passengers) for a given Bus Company
- Returns empty list if `busCompanyId` is null

---

## 5. Testing

**Test Class: `BusStatusUpdateBatch_TEST`**
- Creates 200 buses and assigns 0–25 passengers randomly
- Executes batch and verifies:
  - `<10` passengers → **Available**
  - `11–19` passengers → **Limited Seats**
  - `20` passengers → **Full**
  - `>20` passengers → Status not updated (null)
- Includes test for empty list of IDs

**Test Class: `BusCompanyActions_TEST`**
- Creates a `Bus_Company__c` with 4 buses
- Verifies retrieval of buses with passengers
- Tests null input (returns empty list)

---

## 6. Non-Functional Requirements
- **Scalability:** Batch handles 200+ buses per execution
- **Code Quality:** Readable, modular, exception-safe
- **Test Coverage:** Covers both happy path and edge cases
- **User Experience:** LWC includes loading state, error handling, and clean SLDS layout

---

## 7. Possible Enhancements
- Enforce 20-passenger max at data layer (validation rule or trigger)
- Extend LWC with refresh button to manually re-run batch
- Store batch errors in a custom logging object
- Display capacity usage (%) in LWC
