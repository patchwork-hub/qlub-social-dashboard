# UserRole.where(name: 'community-admin').destroy_all

roles = [
  { name: 'OrganisationAdmin', position: 1010, permissions: %w[manage_channel upload_logo] },
  { name: 'MasterAdmin', position: 1100, permissions: %w[administrator] },
  { name: 'UserAdmin', position: 1200, permissions: %w[manage_channel] }
]

roles.each do |role_attrs|
  permissions = role_attrs[:permissions].reduce(0) do |bitmask, permission|
    if UserRole::FLAGS.key?(permission.to_sym)
      bitmask | UserRole::FLAGS[permission.to_sym]
    else
      raise ArgumentError, "Unknown permission: #{permission}"
    end
  end

  UserRole.find_or_create_by!(name: role_attrs[:name]) do |role|
    role.position = role_attrs[:position]
    role.permissions = permissions
  end
end
