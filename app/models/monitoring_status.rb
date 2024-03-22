class MonitoringStatus < ApplicationRecord
  belongs_to :end_point, foreign_key: 'end_point_id'

end
