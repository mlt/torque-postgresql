module Torque
  module PostgreSQL
    module SchemaAwareness

      def disable_referential_integrity # :nodoc:
        tt = @@schema_aware_modules.map { |m| m.constants.map { |c| m.const_get c } }
                                   .flatten
                                   .select { |c| c < ActiveRecord::Base }
                                   .map(&:table_name)
                                   # .map { |c| quote_table_name c.table_name }
        tt = tables_only(tt)
        begin
          transaction(requires_new: true) do
            execute(tt.collect { |name| "ALTER TABLE #{name} DISABLE TRIGGER ALL" }.join(";"))
          end
        # rescue ActiveRecord::ActiveRecordError
        end

        super

        begin
          transaction(requires_new: true) do
            execute(tt.collect { |name| "ALTER TABLE #{name} ENABLE TRIGGER ALL" }.join(";"))
          end
        # rescue ActiveRecord::ActiveRecordError
        end
      end

      def self.extended(base)
        (@@schema_aware_modules ||= []) << base
      end

      private

      # filter out views
      def tables_only(all)
        query_values(<<~SQL, "SCHEMA")
          select format('%I.%I', relnamespace::regnamespace, relname)
          from pg_class
          where relkind='r' and
            format('%s.%s', relnamespace::regnamespace, relname) in ('#{all.join("','")}');
        SQL
      end
    end

    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include SchemaAwareness
  end
end
