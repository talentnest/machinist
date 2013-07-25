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

      # If we're assigning an AR attribute, use write_attribute in case the direct setter has been overridden
      if @object.attributes.has_key?(key.to_s)
        if @object.class.send(:create_time_zone_conversion_attribute?, key, @object.class.columns_hash[key.to_s])
          # If it's a time attribute, we still want to convert it like Rails would
          time = value
          unless time.acts_like?(:time)
            time = time.is_a?(String) ? Time.zone.parse(time) : time.to_time rescue time
          end
          zoned_time = time && time.in_time_zone rescue nil
          zoned_time.change(usec: 0) if zoned_time
          value = zoned_time || value
        end

        @object.send(:write_attribute, key, value)
      else
        @object.send("#{key}=", value)
      end
    end
  end
end
