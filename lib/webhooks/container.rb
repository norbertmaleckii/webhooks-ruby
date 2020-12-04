module Webhooks
  class Container
    extend Dry::Container::Mixin

    register "signatures.compute_signature_service" do
      Signatures::ComputeSignatureService.new(
        secret: Webhooks.config.secret
      )
    end

    register "signatures.verify_header_service" do
      Signatures::VerifyHeaderService.new(
        secret: Webhooks.config.secret,
        tolerance: Webhooks.config.tolerance,
        scheme: Webhooks.config.scheme
      )
    end

    register "api_service" do
      ApiService.new
    end
  end
end
