require "billimatic/resources/hooks"

module Billimatic
  module Resources
    class Base
      include Wisper::Publisher
      extend Hooks
      attr_accessor :http

      def self.crud(*args)
        @crud ||= args
      end

      def initialize(http)
        @http = http
      end

      def collection_name
        @collection_name ||= underscore_pluralized(base_klass)
      end

      def parsed_body(response)
        MultiJson.load(response.body)
      rescue MultiJson::ParseError
        {}
      end

      def create(params)
        crud_request do
          http.post(resource_base_path, { body: params }) do |response|
            respond_with_entity(response)
          end
        end
      end

      def show(id)
        crud_request do
          http.get("#{resource_base_path}/#{id}") do |response|
            respond_with_entity(response)
          end
        end
      end

      def list
        crud_request do
          http.get(resource_base_path) do |response|
            respond_with_collection(response)
          end
        end
      end

      def destroy(id)
        crud_request do
          http.delete("#{resource_base_path}/#{id}") do |response|
            response.code == 204
          end
        end
      end

      def update(id, params)
        crud_request do
          http.put("#{resource_base_path}/#{id}", { body: params }) do |response|
            respond_with_entity(response)
          end
        end
      end

      notify :create, :destroy

      protected
      def crud_request
        method = caller_locations(1,1)[0].label
        if self.class.crud.include?(:all) || self.class.crud.include?(method.to_sym)
          yield
        else
          raise raise RuntimeError, "#{base_klass} do not implement the #{method} method"
        end
      end

      def respond_with_collection(response, class_name = nil)
        class_name    ||= base_klass
        naked_klass     = entity_klass(class_name)
        hash            = parsed_body(response)
        collection_name = underscore_pluralized(class_name)

        hash[collection_name].map { |item| naked_klass.new(item) }
      end

      def respond_with_entity(response, naked_klass = entity_klass)
        item = parsed_body(response)
        naked_klass.new(item)
      end

      def respond_with_openstruct(response)
        OpenStruct.new(MultiJson.load(response.body))
      end

      def resource_base_path
        @resource_base_path ||= "/#{collection_name}"
      end

      def base_klass
        @base_klass ||= self.class.name.split('::').last
      end

      def entity_klass(class_name = base_klass)
        @entity_klass ||= Billimatic::Entities.const_get(class_name.to_sym)
      end

      def underscore_pluralized(str)
        "#{str.gsub(/(.)([A-Z])/,'\1_\2').downcase}s"
      end

    end
  end
end
