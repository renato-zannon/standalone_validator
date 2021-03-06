class StandaloneValidator
  module NamedValidations
    module CommonRailsOptions
      def self.extract_options!(array)
        if array.last.is_a?(Hash)
          array.pop
        else
          {}
        end
      end

      ALWAYS_TRUE = ->(*) { true }.freeze

      def self.condition_for(options)
        if options.has_key?(:if)
          options[:if].to_proc
        elsif options.has_key?(:unless)
          reverse_condition = options[:unless].to_proc

          ->(*args) {
            negates = instance_exec(*args, &reverse_condition)
            not negates
          }
        else
          ALWAYS_TRUE
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def include_validation(&block)
          super do |object, result|
            if evaluate_condition(object)
              instance_exec(object, result, &block)
            end
          end
        end
      end

      def initialize(*names)
        options = CommonRailsOptions.extract_options!(names)

        @attributes = names
        @options    = options
      end

    private
      attr_reader :attributes, :options

      def evaluate_condition(object)
        instance_exec(object, &condition)
      end

      def condition
        @condition ||= CommonRailsOptions.condition_for(options)
      end

      def each_validated_attribute_on(object)
        return to_enum(:each_validated_attribute, object) unless block_given?

        attributes.each do |attribute_name|
          value = object.send(attribute_name)
          yield(attribute_name, value)
        end
      end
    end
  end
end
