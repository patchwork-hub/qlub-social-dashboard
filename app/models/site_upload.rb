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
  IMAGE_MIME_TYPES = ['image/webp', 'image/png', 'image/gif', 'image/jpeg', 'image/jpg'].freeze
  LIMIT = 2.megabytes

  FAVICON_SIZES = [16, 32, 48].freeze
  APPLE_ICON_SIZES   = [57, 60, 72, 76, 114, 120, 144, 152, 167, 180, 1024].freeze
  ANDROID_ICON_SIZES = [36, 48, 72, 96, 144, 192, 256, 384, 512].freeze

  APP_ICON_SIZES = (APPLE_ICON_SIZES + ANDROID_ICON_SIZES).uniq.freeze

  STYLES = {
    app_icon:
      APP_ICON_SIZES.to_h do |size|
        [:"#{size}", { format: 'png', geometry: "#{size}x#{size}#", file_geometry_parser: FastGeometryParser }]
      end.freeze,

    favicon:
      FAVICON_SIZES.to_h do |size|
        [:"#{size}", { format: 'png', geometry: "#{size}x#{size}#", file_geometry_parser: FastGeometryParser }]
      end.freeze,

    thumbnail: {
      '@1x': {
        format: 'png',
        geometry: '1200x630#',
        file_geometry_parser: FastGeometryParser,
        blurhash: {
          x_comp: 4,
          y_comp: 4,
        }.freeze,
      },

      '@2x': {
        format: 'png',
        geometry: '2400x1260#',
        file_geometry_parser: FastGeometryParser,
      }.freeze,
    }.freeze,

    mascot: {}.freeze,
  }.freeze

  has_attached_file :file, styles: ->(file) { STYLES[file.instance.var.to_sym] }

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
      errors.add(attribute_name, "must be a WEBP, PNG, GIF, or JPG image")
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
    when "favicon"   then :favicon
    when "app_icon"  then :app_icon
    when "thumbnail" then :thumbnail
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
