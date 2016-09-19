module Billimatic
  module Resources
    class Contract < Base
      crud :create

      def search(name)
        http.get(
          "#{resource_base_path}/search", params: { name: name }
        ) do |response|
          respond_with_collection response
        end
      end
    end
  end
end
