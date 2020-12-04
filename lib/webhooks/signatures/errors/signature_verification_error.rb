module Webhooks
  module Signatures
    module Errors
      class SignatureVerificationError < StandardError
        extend Dry::Initializer

        param :message

        option :header
        option :payload
      end
    end
  end
end
