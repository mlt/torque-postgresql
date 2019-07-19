require 'i18n'
require 'ostruct'
require 'active_model'
require 'active_record'
require 'active_support'

require 'active_support/core_ext/hash/compact'
require 'active_record/connection_adapters/postgresql_adapter'

require 'torque/postgresql/config'
require 'torque/postgresql/version'
require 'torque/postgresql/collector'

require 'torque/postgresql/i18n'
require 'torque/postgresql/arel'
require 'torque/postgresql/adapter'
require 'torque/postgresql/attributes'
require 'torque/postgresql/auxiliary_statement'
require 'torque/postgresql/base'
require 'torque/postgresql/inheritance'
require 'torque/postgresql/coder'
require 'torque/postgresql/migration'
require 'torque/postgresql/relation'
require 'torque/postgresql/schema_awareness'
require 'torque/postgresql/schema_cache'
require 'torque/postgresql/schema_dumper'

require 'torque/postgresql/railtie' if defined?(Rails)
