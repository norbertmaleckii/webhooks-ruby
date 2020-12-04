module Webhooks
  module Signatures
    class VerifyHeaderService
      extend Dry::Initializer

      option :secret
      option :tolerance, default: -> { Webhooks::TOLERANCE_DEFAULT }
      option :scheme, default: -> { Webhooks::SCHEME_DEFAULT }

      # Verifies the signature header for a given payload.
      #
      # Raises a SignatureVerificationError in the following cases:
      # - the header does not match the expected format
      # - no signatures found with the expected scheme
      # - no signatures matching the expected signature
      # - a tolerance is provided and the timestamp is not within the
      #   tolerance
      #
      # Returns true otherwise
      def call(header:, payload:)
        timestamp, signatures = get_timestamp_and_signatures(header, payload)

        validates_signatures_scheme(header, payload, signatures)
        validates_signatures_equality(header, payload, timestamp, signatures)
        validates_timestamp_tolerance(header, payload, timestamp)

        true
      end

      private

      # Extracts the timestamp and the signature(s) with the desired scheme
      # from the header
      def get_timestamp_and_signatures(header, payload)
        list_items = header.split(/,\s*/).map { |i| i.split("=", 2) }
        timestamp = Time.at(Integer(list_items.select { |i| i[0] == "t" }[0][1]))
        signatures = list_items.select { |i| i[0] == scheme }.map { |i| i[1] }

        [timestamp, signatures]

      rescue StandardError
        raise Errors::SignatureVerificationError.new(
          "Unable to extract timestamp and signatures from header",
          header: header, payload: payload
        )
      end

      def validates_signatures_scheme(header, payload, signatures)
        raise Errors::SignatureVerificationError.new(
          "No signatures found with expected scheme #{scheme}",
          header: header, payload: payload
        ) if signatures.empty?
      end

      def validates_signatures_equality(header, payload, timestamp, signatures)
        expected_signature = Webhooks::Signatures::ComputeSignatureService.new(
          secret: secret
        ).call(timestamp: timestamp, payload: payload)

        raise Errors::SignatureVerificationError.new(
          "No signatures found matching the expected signature for payload",
          header: header, payload: payload
        ) unless signatures.any? { |s| ActiveSupport::SecurityUtils.secure_compare(expected_signature, s) }
      end

      def validates_timestamp_tolerance(header, payload, timestamp)
        raise Errors::SignatureVerificationError.new(
          "Timestamp outside the tolerance zone (#{timestamp})",
          header: header, payload: payload
        ) if tolerance && timestamp < Time.now - tolerance
      end
    end
  end
end
