module Webhooks
  module Signatures
    class ComputeSignatureService
      extend Dry::Initializer

      option :secret

      # Computes a webhook signature given a time (probably the current time),
      # a payload, and a signing secret.
      def call(timestamp:, payload:)
        validate_parameters(timestamp, payload)

        OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new("sha256"),
          secret,
          "#{timestamp.to_i}.#{payload}"
        )
      end

      private

      def validate_parameters(timestamp, payload)
        raise ArgumentError, "timestamp should be an instance of Time" unless timestamp.is_a?(Time)
        raise ArgumentError, "payload should be a string or a hash" unless payload.is_a?(String) || payload.is_a?(Hash)
        raise ArgumentError, "secret should be a string" unless secret.is_a?(String)
      end
    end
  end
end
