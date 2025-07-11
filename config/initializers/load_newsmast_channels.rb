# frozen_string_literal: true

NEWSMAST_CHANNELS = if File.exist?('newsmast_channels.json')
  JSON.parse(File.read('updated_original_newsmast.json'), symbolize_names: true)
else
  []
end
