module Billimatic
  module Entities
    class Feature < Base
      attribute :id, Integer
      attribute :description, String
      attribute :value, String
      attribute :tag, String
    end
  end
end
