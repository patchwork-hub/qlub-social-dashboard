# frozen_string_literal: true

# == Schema Information
#
# Table name: site_uploads
#
#  id                :bigint(8)        not null, primary key
#  var               :string           default(""), not null
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  meta              :json
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  blurhash          :string
#

class SiteUpload < ApplicationRecord
  IMAGE_MIME_TYPES = ['image/svg+xml', 'image/png', 'image/jpeg', 'image/jpg'].freeze
  LIMIT = 2.megabytes

  has_attached_file :file

  # Paperclip validation
  validates_attachment_content_type :file, content_type: %r{\Aimage/.*\z}

  validate :file_content_type_custom
  validate :file_size_custom

  before_save :set_meta
  after_commit :clear_cache

  def cache_key
    "site_uploads/#{var}"
  end

  private

  def file_content_type_custom
    return unless file.present?

    content_type = (file.respond_to?(:content_type) && file.content_type) || read_attribute(:file_content_type)
    content_type = content_type.to_s.downcase

    unless IMAGE_MIME_TYPES.include?(content_type)
      errors.add(attribute_name, "must be a SVG, PNG or JPG image")
    end
  end

  def file_size_custom
    return unless file.present?

    size = (file.respond_to?(:size) && file.size) || read_attribute(:file_file_size)
    if size.present? && size > LIMIT
      errors.add(attribute_name, "must be smaller than 2MB")
    end
  end

  def attribute_name
    case var
    when "mail_header_logo" then :mail_header_logo
    when "mail_footer_logo" then :mail_footer_logo
    else :file
    end
  end

  def set_meta
    tempfile = file.queued_for_write[:original]

    return if tempfile.nil?

    width, height = FastImage.size(tempfile.path)
    self.meta = { width: width, height: height }
  end

  def clear_cache
    Rails.cache.delete(cache_key)
  end
end
