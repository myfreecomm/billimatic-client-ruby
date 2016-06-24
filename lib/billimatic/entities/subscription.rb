module Billimatic
  module Entities
    class Subscription < Contract
      def checkout_url
        # TODO should this come from the JSON from Billimatic?
        fake_http = nil
        Billimatic::Resources::Subscription.new(fake_http).checkout_url(token: self.token)
      end
    end
  end
end
