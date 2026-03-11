# Kadibs — How It Works

> **Kadibs** is an enterprise-grade Computerized Maintenance Management System (CMMS) designed for engineering firms, manufacturing plants, utilities, oil & gas operations, and facilities management organizations. It helps teams register and manage physical assets, plan and execute maintenance activities, manage spare parts inventory, track technician productivity, and ensure regulatory compliance — all from one unified platform.

---

## Table of Contents

1. [Getting Started](#1-getting-started)
2. [User Roles & Permissions](#2-user-roles--permissions)
3. [Dashboard](#3-dashboard)
4. [Module 1: Organization & Locations](#4-module-1-organization--locations)
5. [Module 2: Asset (Equipment) Management](#5-module-2-asset-equipment-management)
6. [Module 3: Work Order Management](#6-module-3-work-order-management)
7. [Module 4: Preventive Maintenance (PM)](#7-module-4-preventive-maintenance-pm)
8. [Module 5: Inventory & Spare Parts](#8-module-5-inventory--spare-parts)
9. [Module 6: Workforce & Technician Management](#9-module-6-workforce--technician-management)
10. [Module 7: Cost & Financial Tracking](#10-module-7-cost--financial-tracking)
11. [Module 8: Compliance, Safety & Audit](#11-module-8-compliance-safety--audit)
12. [Module 9: Reporting & Analytics](#12-module-9-reporting--analytics)
13. [Module 10: Notifications & Alerts](#13-module-10-notifications--alerts)
14. [Settings & Profile](#14-settings--profile)
15. [API & Integrations](#15-api--integrations)
16. [Typical Workflows](#16-typical-workflows)

---

## 1. Getting Started

### Registration & Login

1. **Register** at `/register` — provide your name, email, password, and optionally a company name.
2. **Login** at `/login` with your email and password.
3. On first login, you'll be directed to your **Dashboard** with an overview of your organization's maintenance KPIs.

### Multi-Tenancy

Kadibs is a multi-tenant platform. Each organization (company) has its own isolated data environment:
- All assets, work orders, parts, locations, and users are scoped to your organization.
- Data from one organization is invisible to another.
- Organization admins control who can access their instance.

---

## 2. User Roles & Permissions

Kadibs uses **role-based access control (RBAC)**. Each user can have one or more roles, and each role determines what they can see and do.

| Role | Description | Key Permissions |
|------|-------------|-----------------|
| **Super Admin** | Platform-level administrator | Full system access, manage all organizations, system settings |
| **Org Admin** | Organization administrator | Full access within their organization, manage users/roles, billing |
| **Manager** | Maintenance manager / supervisor | Create & assign work orders, approve purchase requisitions, view reports |
| **Technician** | Field maintenance technician | View assigned work orders, update progress, log labor/parts, upload photos |
| **Storekeeper** | Inventory / warehouse personnel | Manage parts, process stock movements, handle purchase requisitions |
| **Auditor / Viewer** | Read-only access | View data and reports, no editing capabilities |

### What Each Role Typically Sees

- **Org Admin / Manager**: Full dashboard with all KPIs, all menu items, user management, reports, and configuration.
- **Technician**: Dashboard with their assigned work orders, ability to start/complete tasks, log time and parts used.
- **Storekeeper**: Inventory dashboard, parts catalog, purchase requisitions, stock movements.

---

## 3. Dashboard

**Route:** `/dashboard`

The dashboard is the central hub after login. It displays real-time KPI cards and summary data:

| KPI | Description |
|-----|-------------|
| **Open Work Orders** | Active work orders awaiting completion |
| **Overdue Work Orders** | Work orders past their due date |
| **Low Stock Items** | Parts that have fallen below their reorder level |
| **Pending Requisitions** | Purchase requisitions awaiting approval |
| **Upcoming PMs** | Preventive maintenance tasks scheduled soon |
| **Assets Under Repair** | Equipment currently out of service or under maintenance |

Quick-access links let users jump directly to Work Orders, Equipment, Inventory, or Reports.

---

## 4. Module 1: Organization & Locations

### Organization Settings

**Route:** `/organization`

- View and edit your company's name, domain, contact email, phone, and physical address.
- Manage subscription and billing settings.
- See usage statistics (user count, asset count).

### Locations

**Route:** `/locations`

Locations represent the physical hierarchy of your facilities:

- **Location Types**: Plant, Site, Building, Floor, Zone, Room, Area
- **Hierarchy**: Locations can have parent-child relationships (e.g., _Headquarters → Nairobi Manufacturing Plant → Central Warehouse_)
- **Features**:
  - View all sub-locations and assets assigned to a location
  - Track GPS coordinates with "View Map" links
  - Navigate the full location hierarchy via breadcrumb paths

**Who uses this:**
- **Org Admin / Manager** — Create and organize the location hierarchy
- **Technician** — View where assets are located for field work

---

## 5. Module 2: Asset (Equipment) Management

**Route:** `/equipment`

Assets are the core of Kadibs — every piece of physical equipment your organization owns, operates, or maintains.

### Asset Registry

Each asset record contains:

| Field | Description |
|-------|-------------|
| **Name** | Human-readable name (e.g., "Chiller Unit #1") |
| **Code** | Unique equipment code (e.g., `AST-2025-001`) |
| **Serial Number** | Manufacturer serial number |
| **Category** | Classification (HVAC, Production Machines, Electrical, etc.) |
| **Location** | Where the asset is physically located |
| **Status** | Operational, Under Maintenance, Out of Service, Retired, Decommissioned |
| **Purchase Price / Current Value** | Financial tracking for depreciation |
| **Manufacturer / Model / Year** | Equipment specifications |
| **Warranty Expiry** | When the warranty period ends |
| **Criticality** | Low, Medium, High, Critical — drives priority of maintenance |

### Quick Actions (on the Asset Show Page)

1. **Update Meter** — Record a meter reading (hours, miles, kilometers, or cycles) to trigger meter-based preventive maintenance.
2. **Transfer Asset** — Move the asset to a different location with optional transfer notes. The system records the full transfer history.
3. **Print QR Code** — Generate and print a QR code label for the asset. Scan it from the field to instantly access the asset's record.

### Asset Lifecycle

```
New → Operational → Under Maintenance → Operational → ... → Retired → Decommissioned
```

### Key Features

- **Asset History** — View a timeline of all maintenance activities, transfers, and status changes
- **Linked Work Orders** — See all work orders ever created for this asset
- **Parts Association** — Track which spare parts are compatible with each asset
- **Import / Export** — Bulk import assets via CSV; export the full asset register
- **Categories** — Organize assets by type (HVAC, Electrical, Plumbing, Production, etc.)

**Who uses this:**
- **Manager** — Creates and manages the asset registry, sets criticality levels
- **Technician** — Looks up asset details, scans QR codes in the field, records meter readings
- **Storekeeper** — Links parts to assets for spare parts planning

---

## 6. Module 3: Work Order Management

**Route:** `/work_orders`

Work orders are the primary unit of maintenance work. They track every maintenance task from creation to completion.

### Work Order Types

| Type | Description |
|------|-------------|
| **Corrective** | Fix something after a breakdown or failure |
| **Preventive** | Scheduled routine maintenance task |
| **Predictive** | Triggered by condition monitoring or meter readings |
| **Emergency** | Urgent breakdown that needs immediate attention |

### Work Order Lifecycle

```
Draft → Open → Assigned → In Progress → On Hold → Completed → Verified → Closed
```

Each transition is tracked with timestamps and user attribution. Context-aware action buttons appear based on the current state:

| State | Available Actions |
|-------|-------------------|
| **Open** | Assign, Start |
| **Assigned** | Start, Reassign |
| **In Progress** | Pause, Complete |
| **On Hold** | Resume, Complete |
| **Completed** | Verify, Reopen |
| **Verified** | Close |

### Work Order Contents

- **Title & Description** — What needs to be done
- **Asset** — Which equipment the work is for
- **Priority** — Low, Medium, High, Critical (color-coded)
- **Assigned Technician** — Who is responsible
- **Due Date** — Target completion date
- **Checklists** — Step-by-step task lists that technicians check off
- **Labor Tracking** — Hours worked (regular + overtime) with hourly rates
- **Parts Used** — Which spare parts were consumed and how many
- **Comments** — Threaded discussion between team members
- **Attachments** — Photos, documents, videos uploaded from the field
- **Failure Codes** — Standardized failure classification for root cause analysis
- **Cost Summary** — Auto-calculated total from labor + parts + external costs

**Who uses this:**
- **Manager** — Creates work orders, assigns technicians, reviews completed work, verifies and closes
- **Technician** — Receives assignments, starts/completes work, logs labor hours and parts used, uploads photos
- **Auditor** — Reviews completed work orders for compliance

---

## 7. Module 4: Preventive Maintenance (PM)

**Route:** `/preventive-maintenance`

Preventive maintenance automates the scheduling of routine maintenance tasks to prevent breakdowns.

### PM Schedules

Each PM schedule defines:

| Field | Description |
|-------|-------------|
| **Name** | Description of the PM (e.g., "Monthly HVAC Filter Replacement") |
| **Asset** | Which equipment this PM applies to |
| **Frequency** | How often — value + unit (e.g., every 30 days, every 500 hours) |
| **Frequency Type** | Time-based (calendar) or Meter-based (usage hours, cycles, km) |
| **Next Due Date** | When the next occurrence is scheduled |
| **Task Instructions** | Detailed steps for the technician |
| **Estimated Duration** | How long the PM typically takes |
| **Priority** | Default priority for generated work orders |
| **Active/Inactive** | Whether the schedule is currently generating work orders |

### How It Works

1. **Create a PM Schedule** — Define what, when, and how often.
2. **Auto-Generation** — The system automatically creates work orders when PMs come due (or managers can manually generate with the "Generate Work Order" button).
3. **Tracking** — PM Occurrences track each instance with status (scheduled, completed, overdue, skipped).
4. **Compliance** — The compliance rate is automatically calculated (completed PMs ÷ total PMs × 100%).

### PM Templates

Reusable templates that pre-fill PM schedules for common equipment types (e.g., "Standard Motor Maintenance", "Weekly Generator Check").

### Calendar & Upcoming Views

- **Calendar** — Visual calendar view of all scheduled PMs
- **Upcoming** — List of PMs due in the next 7/14/30 days

**Who uses this:**
- **Manager** — Creates and manages PM schedules, monitors compliance rates
- **Technician** — Receives auto-generated PM work orders, completes them on schedule

---

## 8. Module 5: Inventory & Spare Parts

### Parts Catalog

**Route:** `/parts`

The parts catalog tracks all spare parts and consumables:

| Field | Description |
|-------|-------------|
| **Name** | Part description (e.g., "Air Filter 20x20") |
| **Part Number** | Unique part/SKU number |
| **Category** | Classification (Filters, Bearings, Electrical, etc.) |
| **Quantity On Hand** | Current stock level |
| **Reorder Level** | Minimum stock level before reorder alert triggers |
| **Average Cost** | Weighted average cost per unit |
| **Unit of Measure** | Each, Box, Liter, Meter, etc. |
| **Default Supplier** | Preferred vendor for reordering |
| **Stock Location** | Where in the warehouse this part is stored |

Key indicators:
- 🟢 **In Stock** — Quantity above reorder level
- 🟡 **Low Stock** — Quantity at or below reorder level
- 🔴 **Stockout** — Quantity is zero

### Warehouses & Stock Locations

**Route:** `/warehouses`

- **Warehouses** — Physical storage facilities (e.g., "Main Parts Depot")
- **Stock Locations** — Specific locations within a warehouse (e.g., "Aisle A, Shelf 3, Bin 12")
- Map parts to exact warehouse positions for quick retrieval

### Stock Movements

**Route:** `/stock_movements`

Track every movement of inventory:
- **Receipt** — Parts received from suppliers
- **Issue** — Parts issued to a work order
- **Adjustment** — Manual stock corrections (damaged, counted, written off)
- **Transfer** — Movement between warehouses

Each movement creates an audit trail with timestamp, user, quantity, and reason.

### Suppliers

**Route:** `/suppliers`

Manage your vendor/supplier database:
- Contact information, payment terms, lead times
- Link suppliers to parts they provide
- Track supplier performance

### Purchase Requisitions

**Route:** `/purchase-requisitions`

When parts need to be reordered, purchase requisitions follow an approval workflow:

```
Draft → Pending Approval → Approved → Ordered → Partially Received → Received
                         ↘ Rejected
```

Each PR contains:
- Supplier, needed-by date, shipping address
- Line items (part, quantity, unit cost, total)
- Approval/rejection tracked with timestamps
- Automatic total calculation

**Who uses this:**
- **Storekeeper** — Manages parts catalog, processes stock movements, creates purchase requisitions
- **Manager** — Approves purchase requisitions, reviews inventory reports
- **Technician** — Requests parts for work orders (logged as work order parts usage)

---

## 9. Module 6: Workforce & Technician Management

**Route:** `/users`

### User Profiles

Each user profile contains:
- Name, email, phone, employee ID
- Job title, department
- Timezone, locale preferences
- Role assignments (Admin, Manager, Technician, etc.)
- Account status (Active / Inactive)

### Technician-Specific Features

- **Skills & Certifications** — Track what each technician is certified to do
- **Work Order History** — View all completed and open work orders for a technician
- **Workload Analysis** — See how many active orders each technician has
- **Availability** — Check technician availability for assignment

### Role Assignment

Org Admins and Managers can:
- Assign multiple roles to a user
- Activate/deactivate user accounts
- View user activity and statistics

**Who uses this:**
- **Org Admin** — Creates user accounts, assigns roles, manages access
- **Manager** — Views technician productivity, assigns work orders based on skills and availability
- **Technician** — Views their own profile and work order history

---

## 10. Module 7: Cost & Financial Tracking

### How Costs Are Tracked

Maintenance costs are captured at multiple levels:

| Cost Type | Source |
|-----------|--------|
| **Labor** | Work order labor entries (hours × hourly rate) |
| **Parts** | Work order parts usage (quantity × unit cost) |
| **External** | Contractor and outsourced service costs |
| **Purchasing** | Purchase requisition totals |

### Cost Centers & Budgets

- **Cost Centers** — Organize costs by department, project, or facility
- **Budgets** — Set maintenance budgets and track actual vs. planned spending
- **Budget vs Actual** — Compare budgeted amounts against real expenditures

### Financial Reports

- Total maintenance cost per asset
- Monthly cost trends (line chart)
- Maintenance vs. purchasing cost split
- CAPEX vs. OPEX classification

**Who uses this:**
- **Manager / Org Admin** — Sets budgets, monitors spending, reviews cost reports
- **Finance / Auditor** — Reviews cost breakdowns and financial compliance

---

## 11. Module 8: Compliance, Safety & Audit

### Inspections

**Route:** `/inspections`

Formal inspection records for assets and facilities:
- Inspection checklists with pass/fail items
- Inspector assignment and sign-off
- Status tracking: Scheduled → In Progress → Completed / Failed
- Link inspections to specific assets

### Safety Procedures & Permits

- **Safety Procedures** — Document lockout/tagout procedures, safety protocols
- **Permits to Work** — Formal approval workflow for hazardous work:
  ```
  Draft → Submitted → Approved → Active → Closed
                     ↘ Rejected
  ```

### Compliance Checklists

Regulatory compliance checklists that must be completed periodically:
- Track completion records
- Monitor compliance rates
- Generate compliance reports

### Audit Logs

Every critical action in the system is recorded:
- Who did what, when, and what changed
- Immutable maintenance history
- Accessible to Auditors and Org Admins via the Admin panel

**Who uses this:**
- **Manager** — Creates inspection schedules, manages safety procedures
- **Technician** — Completes inspection checklists, follows safety procedures
- **Auditor** — Reviews compliance records, audit logs, and inspection results

---

## 12. Module 9: Reporting & Analytics

**Route:** `/reports/dashboard`

Kadibs provides interactive reports with **Chart.js** charts and visual analytics.

### Available Reports

| Report | Charts Included | Key Metrics |
|--------|-----------------|-------------|
| **Work Order Analysis** | 🍩 Status doughnut + 📊 Priority bar chart | Total, completed, open, high-priority counts |
| **Asset Performance** | 🍩 Status doughnut + 📊 Category horizontal bar | Total assets, total value, operational count |
| **Cost Analysis** | 📈 Monthly trend line + 🍩 Cost split doughnut | Maintenance costs, purchasing costs, monthly trends |
| **Inventory Valuation** | 🍩 Stock health doughnut + 📊 Top parts by value | Inventory value, low stock, stockout counts |
| **Technician Productivity** | 📊 Grouped workload bar chart | Completed vs. open orders per technician, completion rates |
| **Compliance Analysis** | 📊 Compliance bar chart + 🎯 Gauge chart | Overall compliance rate, overdue PMs, active schedules |

### Key Performance Indicators (KPIs)

- **MTBF** — Mean Time Between Failures
- **MTTR** — Mean Time To Repair
- **PM Compliance Rate** — Percentage of preventive maintenance completed on time
- **Corrective vs. Preventive Ratio** — Balance of reactive vs. proactive maintenance
- **Asset Availability** — Percentage of time assets are operational

### Export

All reports support **CSV export** for external analysis in Excel, Google Sheets, or BI tools.

**Who uses this:**
- **Manager / Org Admin** — Monitors KPIs, identifies trends, makes data-driven decisions
- **Auditor** — Generates compliance and performance reports for regulatory submissions

---

## 13. Module 10: Notifications & Alerts

**Route:** `/notifications`

### In-App Notifications

Real-time notifications appear in the header bell icon with an unread count badge:
- Work order assignments
- Status change updates
- Approval requests
- Overdue reminders
- Low stock alerts

### Alert Types

| Alert | Triggered When |
|-------|----------------|
| **Overdue Work Order** | A work order passes its due date |
| **Upcoming PM** | A preventive maintenance task is due soon |
| **Low Inventory** | A part falls below its reorder level |
| **Asset Failure** | An asset status changes to "Out of Service" |
| **Approval Required** | A purchase requisition needs approval |

### Notification Preferences

Users can configure their notification preferences in Settings — choose which notifications to receive and through which channels.

---

## 14. Settings & Profile

### Profile

**Route:** `/profile`

- View and edit your personal information
- See your role assignments
- View your activity summary (work orders completed, etc.)

### Settings

**Route:** `/settings`

- **Notification Preferences** — Toggle email/in-app notifications per event type
- **Password** — Change your password
- **Organization** — View and switch between organizations (if member of multiple)

---

## 15. API & Integrations

### REST API (v1)

**Base URL:** `/api/v1`

Kadibs provides a full RESTful API for integration with external systems:

| Endpoint | Methods | Description |
|----------|---------|-------------|
| `/api/v1/auth/login` | POST | Authenticate and receive a token |
| `/api/v1/assets` | CRUD | Manage equipment records |
| `/api/v1/work_orders` | CRUD + actions | Manage work orders with lifecycle actions |
| `/api/v1/locations` | CRUD | Manage facility locations |
| `/api/v1/parts` | GET | Query spare parts catalog |
| `/api/v1/pm_schedules` | CRUD | Manage preventive maintenance schedules |
| `/api/v1/users` | GET | Query user directory |
| `/api/v1/webhooks` | CRUD | Configure outgoing webhooks |

### Use Cases for API Integration

- **ERP Systems** — Sync asset and cost data with SAP, Oracle, Dynamics
- **IoT Sensors** — Ingest sensor data for predictive maintenance triggers
- **Mobile Apps** — Power custom mobile applications
- **BI Tools** — Feed real-time data to Power BI, Tableau, or Looker
- **HR Systems** — Sync technician profiles and availability

---

## 16. Typical Workflows

### Workflow A: Corrective Maintenance (Breakdown Repair)

```
1. Equipment breaks down
2. Operator/Manager creates a Work Order (type: Corrective, priority: High)
3. Manager assigns a technician
4. Technician receives notification → starts the work order
5. Technician logs labor hours and parts used
6. Technician uploads photos of the repair
7. Technician marks the work order as Completed
8. Manager verifies the work → marks as Verified
9. Work order is Closed → costs are auto-calculated
```

### Workflow B: Preventive Maintenance Cycle

```
1. Manager creates a PM Schedule (e.g., "Monthly HVAC Filter Change" every 30 days)
2. System auto-generates a Work Order when the PM comes due
3. Technician receives the PM work order
4. Technician follows the checklist, completes the maintenance
5. PM compliance rate is automatically updated
6. Next occurrence is scheduled based on the frequency
```

### Workflow C: Spare Parts Reordering

```
1. Stock level falls below reorder level → Low Stock alert fires
2. Storekeeper creates a Purchase Requisition with line items
3. PR is submitted for approval → Manager receives notification
4. Manager approves (or rejects) the PR
5. Storekeeper marks as Ordered → sends PO to supplier
6. Parts arrive → Storekeeper processes Goods Receipt
7. Stock levels are updated → Stock movement is recorded
```

### Workflow D: Asset Transfer

```
1. Manager or Technician opens the asset page
2. Clicks "Transfer Asset" in Quick Actions
3. Selects new location and adds transfer notes
4. System records the transfer in the asset's history
5. Asset now appears under the new location
```

### Workflow E: Compliance Inspection

```
1. Manager creates an Inspection for a specific asset
2. Inspector receives the assignment
3. Inspector goes through the checklist items (pass/fail each item)
4. Inspector marks the inspection as Completed or Failed
5. Results feed into the compliance reports
6. Auditors can review inspection history at any time
```

---

## Architecture Summary

| Component | Technology |
|-----------|-----------|
| **Backend** | Ruby on Rails (full-stack) |
| **Database** | PostgreSQL |
| **Authentication** | Devise |
| **Authorization** | Pundit (policy-based) |
| **Frontend** | Rails views + Hotwire (Turbo + Stimulus) |
| **Background Jobs** | Sidekiq + Redis |
| **Charts** | Chart.js (via CDN) |
| **File Storage** | Active Storage (S3-compatible) |
| **Multi-Tenancy** | acts_as_tenant (organization-scoped) |

---

*Kadibs — Intelligent maintenance management for the modern enterprise.*
