require 'dry/configurable'
require 'dry/initializer'
require 'dry/auto_inject'

require 'webhooks/signatures/errors/signature_verification_error'
require 'webhooks/signatures/compute_signature_service'
require 'webhooks/signatures/generate_header_service'
require 'webhooks/signatures/verify_header_service'
require 'webhooks/api_service'
require 'webhooks/container'
require 'webhooks/import'
require 'webhooks/version'

module Webhooks
  extend Dry::Configurable

  TOLERANCE_DEFAULT = 300.freeze
  SCHEME_DEFAULT = 'v1'.freeze

  setting :secret
  setting :tolerance, TOLERANCE_DEFAULT
  setting :scheme, SCHEME_DEFAULT

  def self.table_name_prefix
    'webhooks_'
  end
end
