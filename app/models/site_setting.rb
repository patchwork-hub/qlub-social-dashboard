# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id         :bigint(8)        not null, primary key
#  var        :string           not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

require "yaml"

class SiteSetting < ApplicationRecord
  self.table_name = 'settings'

  validate :brand_color_format

  # -------------------------------
  # Value accessor (serialized in YAML)
  # -------------------------------

  # Override setter: store value as YAML format
  def value=(val)
    super(val.to_yaml)
  end

  # Parsed value: returns the actual Ruby object/string
  def parsed_value
    return nil if value.blank?

    YAML.safe_load(value.to_s)
  rescue Psych::SyntaxError
    value.to_s
  end

  # Parsed value setter: stores in YAML format
  def parsed_value=(val)
    self.value = val.to_yaml
  end

  private

  def brand_color_format
    return unless var == "brand_color"

    stripped_value = parsed_value.to_s
    return if stripped_value.empty?

    unless stripped_value =~ /\A#(?:\h{3}|\h{6})\z/i
      errors.add(:brand_color, "must be in hex format like #FFF or #FFFFFF")
    end
  end
end
