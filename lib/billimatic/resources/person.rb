module Billimatic
  module Resources
    class Person < Base
      crud :create, :update, :destroy

      def initialize(http)
        @collection_name = 'people'
        super http
      end

      def show(id)
        http.get("#{resource_base_path}/#{id}") do |response|
          respond_with_entity(response)
        end
      end

      def search(cpf:)
        http.get("#{resource_base_path}/search", params: { cpf: cpf }) do |response|
          respond_with_collection response
        end
      end
    end
  end
end
