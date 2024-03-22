class ContributorRole < ApplicationRecord
	self.table_name = 'mammoth_contributor_roles'

	has_many :wait_lists, inverse_of: :contributor_role
end