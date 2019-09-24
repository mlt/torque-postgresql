module Torque
  module PostgreSQL
    module Associations
      module Preloader
        module Association

          delegate :connected_through_array?, to: :@reflection

          # For reflections connected through an array, make sure to properly
          # decuple the list of ids and set them as associated with the owner
          def run(preloader = nil)
            return super unless connected_through_array?
            send("run_array_for_#{@reflection.macro}")
          end

          private

            # Specific run for belongs_many association
            def run_array_for_belongs_to_many
              # Add reverse to has_many
              records = load_records
              owners.each do |owner|
                items = records.values_at(*Array.wrap(owner[owner_key_name]))
                associate_records_to_owner(owner, items.flatten)
              end
            end

            # Specific run for has_many association
            def run_array_for_has_many
              # Add reverse to belongs_to_many
              records = Hash.new { |h, k| h[k] = [] }
              load_records.each do |ids, record|
                ids.each { |id| records[id].concat(Array.wrap(record)) }
              end

              owners.each do |owner|
                associate_records_to_owner(owner, records[owner[owner_key_name]] || [])
              end
            end

            # Build correctly the constraint condition in order to get the
            # associated ids
            def records_for(ids, &block)
              return super unless connected_through_array?
              condition = scope.arel_attribute(association_key_name)
              condition = reflection.build_id_constraint(condition, ids.flatten.uniq)
              scope.where(condition).load(&block)
            end

            unless Torque::PostgreSQL::AR521
              def associate_records_to_owner(owner, records)
                association = owner.association(reflection.name)
                association.loaded!
                association.target.concat(records)
              end
            end

        end

        ::ActiveRecord::Associations::Preloader::Association.prepend(Association)
      end
    end
  end
end
