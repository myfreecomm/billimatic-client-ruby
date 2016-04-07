module Billimatic
  module Resources
    module Hooks

      def notify(*hooked_methods)
        apply_hooks(hooked_methods.flatten)
      end

      private

      def apply_hooks(hooked_methods)
        hooked_methods.each do |method|
          alias_method "#{method}_without_notifier", method

          define_method method do |*args|
            result = send("#{method}_without_notifier", *args)
            publish("billimatic.#{base_klass.downcase}.#{method}", result, args.flatten)
            result
          end
        end
      end

    end
  end
end
