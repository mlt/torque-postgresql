require 'i18n'
require 'ostruct'
require 'active_model'
require 'active_record'
require 'active_support'

require 'active_support/core_ext/date/acts_like'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/hash/compact' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.5')
require 'active_record/connection_adapters/postgresql_adapter'

require 'torque/postgresql/config'
require 'torque/postgresql/version'
require 'torque/postgresql/collector'
require 'torque/postgresql/geometry_builder'

require 'torque/postgresql/i18n'
require 'torque/postgresql/arel'
require 'torque/postgresql/adapter'
require 'torque/postgresql/associations'
require 'torque/postgresql/attributes'
require 'torque/postgresql/autosave_association'
require 'torque/postgresql/auxiliary_statement'
require 'torque/postgresql/base'
require 'torque/postgresql/inheritance'
require 'torque/postgresql/coder'
require 'torque/postgresql/migration'
require 'torque/postgresql/relation'
require 'torque/postgresql/reflection'
require 'torque/postgresql/schema_cache'
require 'torque/postgresql/schema_dumper'

require 'torque/postgresql/railtie' if defined?(Rails)
