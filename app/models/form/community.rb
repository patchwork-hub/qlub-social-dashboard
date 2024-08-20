# frozen_string_literal: true

# Form::Community is a form object used for handling community-related form data.
# It is not directly associated with a database table but manages form inputs

class Form::Community
  include ActiveModel::Model

  attr_accessor :id, :username, :collection_id, :bio, :banner_image, :avatar

  def initialize(options = {})
    options = options.symbolize_keys
    @username = options.fetch(:username) if options[:username]
    @collection_id = options.fetch(:collection_id) if options[:collection_id]
    @bio = options.fetch(:bio, nil) if options[:bio]
    @banner_image = options.fetch(:banner_image, nil) if options[:banner_image]
    @avatar = options.fetch(:avatar, nil) if options[:avatar]
  end
end
