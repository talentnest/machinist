module Machinist::ActiveRecord

  class Lathe < Machinist::Lathe

    def make_one_value(attribute, args) #:nodoc:
      if block_given?
        raise_argument_error(attribute) unless args.empty?
        yield
      else
        make_association(attribute, args)
      end
    end

    def make_association(attribute, args) #:nodoc:
      association = @klass.reflect_on_association(attribute)
      if association
        association.klass.make(*args)
      else
        raise_argument_error(attribute)
      end
    end

    def assign_attribute(key, value) #:nodoc:
      @assigned_attributes[key.to_sym] = value

      if @object.attributes.has_key?(key.to_s)
        @object.send(:write_attribute, key, value)
      else
        @object.send("#{key}=", value)
      end
    end
  end
end
