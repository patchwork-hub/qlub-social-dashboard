# == Schema Information
#
# Table name: relays
#
#  id                 :bigint           not null, primary key
#  inbox_url          :string           default(""), not null
#  state              :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  follow_activity_id :string
#
class Relay < ApplicationRecord
end
