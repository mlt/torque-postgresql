module Torque
  module PostgreSQL
    module Adapter
      module ColumnMethods

        # Creates a column with an interval type, allowing span of times and
        # dates to be stored without having to store a seconds-based integer
        # or any sort of other approach
        def interval(*args, **options)
          args.each { |name| column(name, :interval, options) }
        end

        # Creates a column with an enum type, needing to specify the subtype,
        # which is basically the name of the type defined prior creating the
        # column
        def enum(*args, **options)
          args.each do |name|
            type = options.fetch(:subtype, name)
            column(name, type, options)
          end
        end

        # Creates a column with an enum array type, needing to specify the
        # subtype, which is basically the name of the type defined prior
        # creating the column
        def enum_set(*args, **options)
          super(*args, **options.merge(array: true))
        end

      end

      module TableDefinition
        include ColumnMethods

        attr_reader :inherits

        def initialize(*args, **options)
          if Torque::PostgreSQL::AR6
            super(*args, options)
          else
            args << options.delete(:temporary) || false
            args << options.delete(:options)
            args << options.delete(:as)
            comment = options.delete(:comment)
            super(*args, comment: comment)
          end

          if options.key?(:inherits)
            @inherits = Array[options.delete(:inherits)].flatten.compact
            @inherited_id = !(options.key?(:primary_key) || options.key?(:id))
          end
        end

        def inherited_id?
          @inherited_id
        end
      end

      ActiveRecord::ConnectionAdapters::PostgreSQL::Table.include ColumnMethods
      ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.include TableDefinition

      if ActiveRecord::ConnectionAdapters::PostgreSQL.const_defined?('ColumnDefinition')
        module ColumnDefinition
          attr_accessor :subtype
        end

        ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnDefinition.include ColumnDefinition
      end
    end
  end
end
