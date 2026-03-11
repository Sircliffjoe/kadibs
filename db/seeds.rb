# Find existing admin user or create if not exists
admin_email = "kadmin@kadibs.com"
admin = User.find_by(email: admin_email)

if admin.nil?
  puts "Creating Admin User..."
  # Create a default organization first if needed
  org = Organization.find_or_create_by!(name: "KADIBS ENGINEERING SERVICES LIMITED") do |o|
    o.slug = "kadibs-engineering"
    o.plan = "enterprise"
    o.email = admin_email
  end

  admin = User.new(
    email: admin_email,
    password: "Nathan.2020!",
    password_confirmation: "Nathan.2020!",
    first_name: "Eventro",
    last_name: "Admin",
    super_admin: true,
    confirmed_at: Time.current
  )
  admin.organization = org
  admin.save!
else
  puts "Found existing admin user: #{admin.email}"
    # Ensure organization is set correctly if missing
    if admin.organization.nil?
    org = Organization.find_or_create_by!(name: "KADIBS ENGINEERING SERVICES LIMITED") do |o|
      o.slug = "kadibs-engineering"
      o.plan = "enterprise"
    end
    admin.update!(organization: org)
    else
    org = admin.organization
    end
end

# Make sure admin has admin role
role = Role.find_or_create_by!(slug: "admin", organization: org) do |r|
  r.name = "Administrator"
  r.description = "Administrator with full access"
end
UserRole.find_or_create_by!(user: admin, role: role) do |ur|
  ur.assigned_by = admin
end

puts "Seeding data for Organization: #{org.name}..."

# ---------------------------------------------------------------------------
# LOCATIONS
# ---------------------------------------------------------------------------
puts "Creating Locations..."
hq = Location.find_or_create_by!(name: "Headquarters", organization: org) do |l|
  l.code = "HQ-01"
  l.location_type = "building"
  l.description = "Main Corporate Office"
  l.address = { "street" => "123 Innovation Drive", "city" => "Nairobi", "country" => "Kenya" }
end

factory = Location.find_or_create_by!(name: "Nairobi Manufacturing Plant", organization: org) do |l|
  l.code = "MFG-01"
  l.location_type = "plant"
  l.description = "Primary manufacturing facility"
  l.parent = hq
  l.address = { "street" => "45 Industrial Area", "city" => "Nairobi", "country" => "Kenya" }
end

warehouse_loc = Location.find_or_create_by!(name: "Central Warehouse", organization: org) do |l|
  l.code = "WH-01"
  l.location_type = "building"
  l.description = "Main distribution center"
  l.parent = factory
end

# ---------------------------------------------------------------------------
# WAREHOUSES & STOCK LOCATIONS
# ---------------------------------------------------------------------------
puts "Creating Warehouses..."
main_warehouse = Warehouse.find_or_create_by!(name: "Main Parts Depot", organization: org) do |w|
  w.code = "WH-MAIN"
  w.location = warehouse_loc
  w.description = "Primary storage for spare parts"
end

aisle_a = StockLocation.find_or_create_by!(name: "Aisle A", warehouse: main_warehouse) do |sl|
  sl.code = "A-01"
  sl.aisle = "A"
  sl.location_type = "shelf"
end

aisle_b = StockLocation.find_or_create_by!(name: "Aisle B", warehouse: main_warehouse) do |sl|
  sl.code = "B-01"
  sl.aisle = "B"
  sl.location_type = "bin"
end

# ---------------------------------------------------------------------------
# USERS (TECHNICIANS)
# ---------------------------------------------------------------------------
puts "Creating Technicians..."
tech_role = Role.find_or_create_by!(slug: "technician", organization: org) do |r|
  r.name = "Technician"
  r.description = "Maintenance Technician"
end

tech1 = User.find_by(email: "tech1@example.com")
if tech1.nil?
  tech1 = User.new(
    email: "tech1@example.com",
    password: "password123",
    first_name: "John",
    last_name: "Doe",
    confirmed_at: Time.current
  )
  tech1.organization = org
  tech1.save!
end

UserRole.find_or_create_by!(user: tech1, role: tech_role) do |ur|
  ur.assigned_by = admin
end

tech2 = User.find_by(email: "tech2@example.com")
if tech2.nil?
  tech2 = User.new(
    email: "tech2@example.com",
    password: "password123",
    first_name: "Jane",
    last_name: "Smith",
    confirmed_at: Time.current
  )
  tech2.organization = org
  tech2.save!
end

UserRole.find_or_create_by!(user: tech2, role: tech_role) do |ur|
  ur.assigned_by = admin
end

# ---------------------------------------------------------------------------
# ASSET CATEGORIES & ASSETS
# ---------------------------------------------------------------------------
puts "Creating Assets..."
hvac_cat = AssetCategory.find_or_create_by!(name: "HVAC", organization: org) do |c|
  c.code = "HVAC"
  c.description = "Heating, Ventilation, and Air Conditioning"
end

production_cat = AssetCategory.find_or_create_by!(name: "Production Machines", organization: org) do |c|
  c.code = "PROD"
  c.description = "Manufacturing Equipment"
end

asset1 = Asset.find_or_create_by!(name: "Chiller Unit #1", organization: org) do |a|
  a.code = "HVAC-001"
  a.asset_category = hvac_cat
  a.location = factory
  a.status = "operational"
  a.model = "Carrier 30XA"
  a.serial_number = "SN-12345678"
  a.purchase_date = 2.years.ago
  a.purchase_price = 45000.00
  a.current_value = 38000.00
  a.criticality = "high"
end

asset2 = Asset.find_or_create_by!(name: "Conveyor Belt System", organization: org) do |a|
  a.code = "CNV-001"
  a.asset_category = production_cat
  a.location = factory
  a.status = "under_maintenance"
  a.model = "Siemens BeltPro"
  a.serial_number = "SN-98765432"
  a.purchase_date = 1.year.ago
  a.purchase_price = 12000.00
  a.current_value = 10000.00
  a.criticality = "medium"
end

asset3 = Asset.find_or_create_by!(name: "Main Generator", organization: org) do |a|
  a.code = "GEN-01"
  a.asset_category = production_cat
  a.location = warehouse_loc
  a.status = "operational"
  a.model = "Caterpillar C32"
  a.serial_number = "CAT-GEN-99"
  a.purchase_date = 5.years.ago
  a.purchase_price = 85000.00
  a.current_value = 45000.00
  a.criticality = "critical"
end

# ---------------------------------------------------------------------------
# SUPPLIERS & PARTS
# ---------------------------------------------------------------------------
puts "Creating Inventory..."
supplier1 = Supplier.find_or_create_by!(name: "Global Industrial Supply", organization: org) do |s|
  s.code = "SUP-01"
  s.contact_name = "Mike Ross"
  s.email = "orders@globalindustrial.com"
  s.phone = "+1-555-0199"
end

part1 = Part.find_or_create_by!(name: "Air Filter 20x20", organization: org) do |p|
  p.part_number = "FIL-2020"
  p.description = "Standard HVAC Air Filter"
  p.unit_cost = 15.50
  p.quantity_on_hand = 50
  p.reorder_level = 10
  p.default_stock_location = aisle_a
  p.preferred_supplier = supplier1
end

part2 = Part.find_or_create_by!(name: "Conveyor Belt Bearing", organization: org) do |p|
  p.part_number = "BRG-6204"
  p.description = "Ball bearing for conveyor rollers"
  p.unit_cost = 8.25
  p.quantity_on_hand = 100
  p.reorder_level = 20
  p.default_stock_location = aisle_b
  p.preferred_supplier = supplier1
end

part3 = Part.find_or_create_by!(name: "Generator Oil Filter", organization: org) do |p|
  p.part_number = "OIL-GEN-01"
  p.description = "Heavy duty oil filter"
  p.unit_cost = 45.00
  p.quantity_on_hand = 5
  p.reorder_level = 5
  p.default_stock_location = aisle_a
  p.preferred_supplier = supplier1
end

# ---------------------------------------------------------------------------
# WORK ORDERS
# ---------------------------------------------------------------------------
puts "Creating Work Orders..."
# Completed WO
WorkOrder.create!(
  title: "Replace HVAC Filters",
  description: "Routine quarterly filter replacement for Chiller Unit #1",
  organization: org,
  asset: asset1,
  assigned_to: tech1,
  status: "completed",
  priority: "medium",
  work_order_type: "preventive",
  due_date: 1.week.ago,
  completed_at: 1.week.ago
)

# In Progress WO
WorkOrder.create!(
  title: "Repair Conveyor Belt",
  description: "Belt is slipping and making noise. Check tensioner and variance.",
  organization: org,
  asset: asset2,
  assigned_to: tech2,
  status: "in_progress",
  priority: "high",
  work_order_type: "corrective",
  due_date: Time.current + 2.days
)

# Open WO
WorkOrder.create!(
  title: "Generator Monthly Test",
  description: "Run generator on load for 30 minutes and check parameters.",
  organization: org,
  asset: asset3,
  status: "open",
  priority: "critical",
  work_order_type: "preventive",
  due_date: Time.current + 1.day
)

# ---------------------------------------------------------------------------
# PM SCHEDULES
# ---------------------------------------------------------------------------
puts "Creating PM Schedules..."
PreventiveMaintenanceSchedule.create!(
  name: "Monthly HVAC Inspection",
  description: "Inspect belts, check freon levels, clean coils.",
  organization: org,
  asset: asset1,
  frequency_value: 1,
  frequency_unit: "months",
  schedule_type: "time_based",
  next_due_date: Time.current + 15.days,
  default_assignee: tech1,
  active: true
)

PreventiveMaintenanceSchedule.create!(
  name: "Weekly Generator Start",
  description: "No-load test run for 15 minutes.",
  organization: org,
  asset: asset3,
  frequency_value: 1,
  frequency_unit: "weeks",
  schedule_type: "time_based",
  next_due_date: Time.current + 3.days,
  default_assignee: tech2,
  active: true
)

# ---------------------------------------------------------------------------
# INSPECTIONS
# ---------------------------------------------------------------------------
puts "Creating Inspections..."
inspection = Inspection.create!(
  title: "Monthly Safety Walkthrough",
  description: "General facility safety inspection.",
  organization: org,
  inspector: tech1,
  status: "in_progress",
  asset: asset2,
  scheduled_date: Time.current
)

InspectionItem.create!(inspection: inspection, description: "Fire extinguishers charged", position: 1, checked: true)
InspectionItem.create!(inspection: inspection, description: "Walkways clear of debris", position: 2, checked: false, notes: "Pallet blocking Aisle 4")
InspectionItem.create!(inspection: inspection, description: "Emergency lights functional", position: 3)

# ---------------------------------------------------------------------------
# PURCHASE REQUISITIONS
# ---------------------------------------------------------------------------
puts "Creating Purchase Requisitions..."
pr = PurchaseRequisition.create!(
  number: "PR-#{Time.current.year}-001",
  organization: org,
  requested_by: tech1,
  supplier: supplier1,
  notes: "Urgent parts for Conveyor repair",
  status: "pending_approval",
  required_date: Time.current + 3.days
)

PurchaseRequisitionItem.create!(
  purchase_requisition: pr,
  part: part2,
  quantity_requested: 10,
  unit_price: 8.25
)

puts "Seeding Complete! Login with:"
puts "Email: #{admin_email}"
puts "Password: Nathan.2020!"
