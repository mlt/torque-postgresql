require 'spec_helper'

RSpec.describe 'Geometries' do
  context 'on build' do
    let(:klass) do
      klass = Class.new(Torque::PostgreSQL::GeometryBuilder)
      klass.define_singleton_method(:name) { 'TestSample' }
      klass.const_set('PIECES', %i[a b c d].freeze)
      klass.const_set('FORMATION', '(%s, %s, <%s, {%s}>)'.freeze)
      klass
    end

    let(:instance) { klass.new }

    context '#type' do
      it 'originally does not have the constant defined' do
        expect(klass.constants).not_to include('TYPE')  
      end

      it 'creates the type constant based on the name' do
        expect(instance.type).to be_eql('test_sample')
        expect(klass.constants).to include(:TYPE)
        expect(klass::TYPE).to be_eql('test_sample')
      end

      it 'returns the constant value' do
        klass.const_set('TYPE', 'another_type')
        expect(instance.type).to be_eql('another_type')
      end
    end

    context '#pieces' do 
      it 'returns the definition pieces' do
        expect(instance.pieces).to be_eql([:a, :b, :c, :d])
      end
      it 'returns whatever is in the constant' do
        klass.const_set('PIECES', %i[a].freeze)
        expect(instance.pieces).to be_eql([:a])
      end
    end

    context '#formation' do 
      it 'returns the definition set' do
        expect(instance.formation).to be_eql("(%s, %s, <%s, {%s}>)")
      end

      it 'returns whatever is in the constant' do
        klass.const_set('FORMATION', '(<%s>)'.freeze)
        expect(instance.formation).to be_eql("(<%s>)")
      end
    end

    context '#cast' do 
      let(:config_class) { double }
      
      before { allow(instance).to receive(:config_class).and_return(config_class) }

      it 'accepts string values' do
        expect(instance.cast('')).to be_nil

        expect(config_class).to receive(:new).with(1, 2, 3, 4).and_return(4)
        expect(instance.cast('1, 2 ,3 ,4')).to be_eql(4)

        expect(config_class).to receive(:new).with(1, 2, 3, 4).and_return(4)
        expect(instance.cast('(1, {2} ,<3> ,4)')).to be_eql(4)

        expect(config_class).to receive(:new).with(1, 2, 3, 4).and_return(4)
        expect(instance.cast('1, 2 ,3 ,4, 5, 6')).to be_eql(4)

        expect(config_class).to receive(:new).with(1.0, 2.0, 3.0, 4.0).and_return(4)
        expect(instance.cast('1.0, 2.0 ,3.0 ,4.0')).to be_eql(4)

        expect { instance.cast(["6 6 6"]) }.to raise_error(RuntimeError, 'Invalid format')
      end

      it 'accepts hash values' do
        expect(instance.cast({})).to be_nil

        expect { instance.cast({ 'a' => 1, 'b' => 2 }) }.to raise_error(RuntimeError, 'Invalid format')

        expect(config_class).to receive(:new).with( 1, 2, 3, 4 ).and_return(4)
        expect(instance.cast({ 'a' => 1, 'b' => 2 , 'c' => 3, 'd' => 4})).to be_eql(4)

        expect(config_class).to receive(:new).with( 1.0, 2.0, 3.0, 4.0 ).and_return(4)
        expect(instance.cast({ 'a' => 1.0, 'b' => 2.0, 'c' => 3.0, 'd' => 4.0})).to be_eql(4)

        expect(config_class).to receive(:new).with( 1, 2, 3, 4 ).and_return(4)
        expect(instance.cast({ 'a' => 1, 'b' => 2 , 'c' => 3, 'd' => 4, 'e' => 5, 'f' => 6})).to be_eql(4)

      end

      it 'accepts array values' do
        expect(config_class).to receive(:new).with(1, 2, 3, 4).and_return(4)
        expect(instance.cast([1, 2, 3, 4])).to be_eql(4)

        expect(config_class).to receive(:new).with(1.1, 1.2, 1.3, 1.4).and_return(9)
        expect(instance.cast(['1.1', '1.2', '1.3', '1.4'])).to be_eql(9)

        expect(config_class).to receive(:new).with(6, 5, 4, 3).and_return(9)
        expect(instance.cast([6, 5, 4, 3, 2, 1])).to be_eql(9)

        expect(instance.cast([])).to be_nil

        expect { instance.cast([6, 5, 4]) }.to raise_error(RuntimeError, 'Invalid format')
      end
    end

    context '#serialize' do
      before { allow(instance).to receive(:config_class).and_return(OpenStruct) }

      it 'return value nil' do
        expect(instance.serialize(nil)).to be_nil
      end

      it 'accepts config class' do
        expect(instance.serialize(OpenStruct.new)).to be_nil
        expect(instance.serialize(OpenStruct.new(a: 1, b: 2, c: 3, d: 4))).to be_eql('(1, 2, <3, {4}>)')
        expect(instance.serialize(OpenStruct.new(a: 1, b: 2, c: 3, d: 4, e: 5))).to be_eql('(1, 2, <3, {4}>)')
      end

      it 'accepts hash value' do
        expect { instance.cast({a: 1, b: 2, c: 3}) }.to raise_error(RuntimeError, 'Invalid format')
        expect(instance.serialize({a: 1, b: 2, c: 3, d: 4})).to be_eql('(1, 2, <3, {4}>)')
        expect(instance.serialize({a: 1, b: 2, c: 3, d: 4, e: 5, f: 6})).to be_eql('(1, 2, <3, {4}>)')
      end

      it 'accepts array value' do
        expect { instance.serialize([6, 5, 4]) }.to raise_error(RuntimeError, 'Invalid format')
        expect(instance.serialize([1, 2, 3, 4])).to be_eql('(1, 2, <3, {4}>)')
        expect(instance.serialize([1, 2, 3, 4, 5, 6])).to be_eql('(1, 2, <3, {4}>)')
      end

    end

    context '#deserialize' do
      let(:config_class) { double }
      
      before { allow(instance).to receive(:config_class).and_return(config_class) }

      it 'return value nil' do
        expect(instance.deserialize(nil)).to be_nil
      end

      it 'accept correct format' do 
        expect(config_class).to receive(:new).with(1, 2, 3, 4).and_return(6)
        expect(instance.deserialize('(1, 2, <3, {4}>)')).to be_eql(6)
      end
    end

    context '#type_cast_for_schema' do
      before { allow(instance).to receive(:config_class).and_return(OpenStruct) }

      it 'config_class' do
        expect(instance.type_cast_for_schema(OpenStruct.new(a: 1, b: 2, c: 3, d: 4))).to be_eql([1, 2, 3, 4])
      end
    end
  end

  context 'on box' do
    let(:klass) { Torque::PostgreSQL.config.geometry.box_class }
  end

  context 'on circle' do
    let(:klass) { Torque::PostgreSQL.config.geometry.circle_class }
  end

  context 'on line' do
    let(:klass) { Torque::PostgreSQL.config.geometry.line_class }
  end

  context 'on segment' do
    let(:klass) { Torque::PostgreSQL.config.geometry.segment_class }
  end
end