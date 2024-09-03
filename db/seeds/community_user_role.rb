UserRole.find_or_create_by(name: 'community-admin') do |user_role|
  user_role.color = #000111
  user_role.position = 6
  user_role.permissions = 0
  user_role.highlighted = false
end
p 'community-admin are created!!'