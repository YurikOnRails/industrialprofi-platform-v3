puts '🌱 Generating development environment seeds.'

# Load permit types data
require_relative 'permit_types'

# Create default permit types for each team (idempotent)
Team.find_each do |team|
  PERMIT_TYPES_DATA.each do |attrs|
    team.permit_types.find_or_create_by!(name: attrs[:name]) do |pt|
      pt.assign_attributes(attrs.except(:name))
    end
  end
end

puts "✅ Permit types seeded: #{PermitType.count} total"
