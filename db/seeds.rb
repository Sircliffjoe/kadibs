# =============================================================================
# KADIBS ENGINEERING SERVICES LIMITED — Seed File
# =============================================================================
# Creates the company organization (required by the data model) and the
# platform admin user. That's it — no demo data.
# =============================================================================

# Organization (single, internal — not a SaaS tenant)
org = Organization.find_or_create_by!(name: "KADIBS ENGINEERING SERVICES LIMITED") do |o|
  o.slug  = "kadibs-engineering"
  o.plan  = "enterprise"
  o.email = "kadibsengrgservicesltd@gmail.com"
end

# Platform Admin
admin_email = "kadmin@kadibs.com"

unless User.exists?(email: admin_email)
  admin = User.new(
    email:                 admin_email,
    password:              "Kadibs@2026!!",
    password_confirmation: "Kadibs@2026!!",
    first_name:            "Kadibs",
    last_name:             "Admin",
    super_admin:           true,
    confirmed_at:          Time.current
  )
  admin.organization = org
  admin.save!
  puts "Admin user created: #{admin_email}"
else
  puts "Admin user already exists: #{admin_email}"
end
