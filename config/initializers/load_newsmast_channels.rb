# frozen_string_literal: true

NEWSMAST_CHANNELS = if File.exist?('newsmast_channels.json')
  JSON.parse(File.read('newsmast_channels.json'))
else
  []
end
