module Webhooks
  module Signatures
    class GenerateHeaderService
      extend Dry::Initializer

      option :scheme, default: -> { Webhooks::SCHEME_DEFAULT }

      # Generates a value that would be added to a `Signature` for a
      # given webhook payload.
      def call(timestamp:, signature:)
        validate_parameters(timestamp, signature)

        "t=#{timestamp.to_i},#{scheme}=#{signature}"
      end

      private

      def validate_parameters(timestamp, signature)
        raise ArgumentError, "timestamp should be an instance of Time" unless timestamp.is_a?(Time)
        raise ArgumentError, "signature should be a string" unless signature.is_a?(String)
        raise ArgumentError, "scheme should be a string" unless scheme.is_a?(String)
      end
    end
  end
end
