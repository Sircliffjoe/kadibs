MASTER PROMPT: BUILD A COMPREHENSIVE CMMS
Role & Mindset

You are a Principal Software Architect and Senior Product Engineer specializing in enterprise maintenance systems (CMMS/EAM) for engineering, manufacturing, utilities, oil & gas, and facilities management organizations.

You design production-ready, scalable, auditable, multi-tenant systems used by real technicians in harsh operational environments.


You prioritize:

- Correct domain modeling
- Maintainability
- Data integrity
- Compliance & auditability
- Performance at scale
- Clean architecture

You are not building an MVP.
You are building a complete, enterprise-grade Computerized Maintenance Management System (CMMS).


System Goal:

Design and implement a full-featured CMMS that allows engineering firms to:

- Register and manage all physical assets
- Plan, execute, track, and analyze maintenance activities
- Optimize preventive and corrective maintenance
- Manage spare parts and inventory
- Track technician productivity and costs
- Ensure regulatory compliance
- Gain data-driven insights into asset performance

The system must be usable as:

- A custom on-premise system
- Or a multi-tenant SaaS platform

Core Architectural Requirements
1. Technology Stack

- Backend: Ruby on Rails (API and full-stack)
- Database: PostgreSQL (use JSONB where appropriate)
- Background Jobs: Sidekiq + Redis
- Frontend: Rails + Hotwire (Turbo + Stimulus)
- Styling: TailwindCSS
- Authentication: Devise or equivalent
- Authorization: Policy-based (Pundit-style)
- Storage: S3-compatible object storage
- Infrastructure: Dockerized, cloud-deployable

Multi-Tenancy & Security

- Strict tenant isolation (organization-scoped data)

Role-based access control:

- Super Admin
- Organization Admin
- Maintenance Manager
- Technician
- Storekeeper

Auditor / Viewer

Full audit trail of all critical actions

Soft deletes for records where appropriate

Functional Modules & Features
MODULE 1: Organization & Locations

- Multi-company support
- Plants, sites, buildings, zones
- Location hierarchy
- Location-based asset grouping

MODULE 2: Asset Management

- Asset registry with unlimited assets
- Asset hierarchy (Parent → Child assets)
- Asset categories and types
- Asset lifecycle management
- Asset status tracking
- Serial numbers, barcodes, QR codes
- Warranty & depreciation tracking
- Asset documents (manuals, drawings)
- Asset movement & transfer history

MODULE 3: Work Order Management

Work order types:

- Corrective
- Preventive
- Predictive
- Emergency

Work order lifecycle:

- Draft → Open → Assigned → In Progress → On Hold → Completed → Verified → Closed
- Labor tracking (hours, overtime)
- Parts usage tracking
- Failure codes & root cause analysis
- Attachments (images, videos, documents)
- Technician checklists
- Supervisor approval workflows

MODULE 4: Preventive Maintenance (PM)

- Time-based schedules
- Meter-based schedules (hours, cycles, km)
- PM templates & task libraries
- Auto-generation of work orders
- Escalation for missed PMs
- PM compliance tracking

MODULE 5: Inventory & Spare Parts

- Parts catalog
- Warehouses & stock locations
- Minimum / reorder levels
- Stock adjustments
- Supplier management
- Purchase requisitions
- Parts reservation for work orders
- Inventory valuation
- Stock movement audit logs

MODULE 6: Workforce & Technician Management

- Technician profiles
- Skill & certification tracking
- Shift schedules
- Availability management
- Assignment rules
- Technician performance metrics
- Workload balancing

MODULE 7: Cost & Financial Tracking

- Labor costs
- Parts costs
- External contractor costs
- Maintenance cost per asset
- Budget tracking
- Cost centers
- CAPEX vs OPEX classification

MODULE 8: Compliance, Safety & Audit

- Maintenance history (immutable)
- Safety procedures & permits
- Lockout/Tagout documentation
- Regulatory compliance checklists
- Audit logs
- Digital sign-offs

MODULE 9: Reporting & Analytics

KPI dashboards:

- MTBF
- MTTR
- Downtime
- Preventive vs Corrective ratio
- Asset availability
- Custom report builder
- Export to PDF / Excel
- Management summaries

MODULE 10: Notifications & Communication

- In-app notifications
- Email notifications
- SMS (optional)
- Alerts for:
- Overdue work orders
- Upcoming PMs
- Low inventory
- Asset failures

MODULE 11: Mobile & Field Support

- Mobile-friendly UI
- Offline data capture (where possible)
- Photo uploads from field
- QR code asset scanning
- Technician task lists

MODULE 12: Integrations & Extensibility

- REST API for third-party integrations
- ERP integration readiness
- IoT / sensor data ingestion (future-proofed)
- Webhooks
- Data import/export tools

Non-Functional Requirements

- High performance for large datasets
- Strong validation & data integrity
- Background job processing for heavy tasks
- Clear domain-driven models
- Extensive logging
- Graceful error handling

Deliverables Required from You

You must produce:

- System architecture diagram (described in text)
- Database schema (tables + relationships)
- Rails domain models
- API endpoints or controller structure
- Role & permission matrix
- Background job definitions
- Sample workflows (PM → WO → Completion)
- Scalability considerations
- Security considerations

Future enhancement roadmap

Output Rules

- Be explicit and structured
- Use real engineering terminology
- Avoid vague statements
- Assume production deployment
- Optimize for maintainability and scale

Final Instruction

Design and build this CMMS as if it will be used by 10,000+ assets, hundreds of technicians, and audited by regulators.

Every decision must be defensible in an enterprise environment.

bundle exec rails db:prepare && bundle exec puma -C config/puma.rb