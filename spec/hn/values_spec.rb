RSpec.describe Hn::Rollup::Value do

  it 'creates a value' do
    expect(Hn::Rollup::Value.new('')).to be_a Hn::Rollup::Value
  end

  describe 'Hn::Rollup::Value::make' do

    context 'with canonical representation' do

      it 'selects the correct dimension for value' do
        expect(Hn::Rollup::Value.make({ 'null' => nil })).to be_a Hn::Rollup::Value::Null
        expect(Hn::Rollup::Value.make({ 'boolean' => true })).to be_a Hn::Rollup::Value::Boolean
        expect(Hn::Rollup::Value.make({ 'number' => 9 })).to be_a Hn::Rollup::Value::Number
        expect(Hn::Rollup::Value.make({ 'string' => 'foo' })).to be_a Hn::Rollup::Value::String
      end

    end

    context 'with untagged representation' do

      it 'selects the correct dimension for value' do
        expect(Hn::Rollup::Value.make(nil)).to be_a Hn::Rollup::Value::Null
        expect(Hn::Rollup::Value.make(true)).to be_a Hn::Rollup::Value::Boolean
        expect(Hn::Rollup::Value.make(9)).to be_a Hn::Rollup::Value::Number
        expect(Hn::Rollup::Value.make('foo')).to be_a Hn::Rollup::Value::String
      end

    end

  end

  describe Hn::Rollup::Value::Null do

    it 'creates a null value' do
      expect(Hn::Rollup::Value::Null.new(nil)).to be_a Hn::Rollup::Value::Null
      expect(Hn::Rollup::Value::Null.new({ 'null' => nil })).to be_a Hn::Rollup::Value::Null
    end

    it 'rejects an invalid value' do
      expect { Hn::Rollup::Value::Null.new('non-null') }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Null.new({ 'null' => 'non-null' }) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Null.new({ 'non-null' => nil }) }.to raise_error(Hn::Rollup::Error)
    end

    context 'with valid value' do

      let(:current) { Hn::Rollup::Value::Null.new({ 'null' => nil }) }
      let(:other) { Hn::Rollup::Value::Null.new({ 'null' => nil }) }

      it "produces a valid value" do
        expect(current.reduce).to be_nil
        expect(current.canonical).to eq({ 'null' => nil })
      end

      it "aggregates with a sibling" do
        expect(current.aggregate_sibling(other).reduce).to be_nil
      end

      it "aggregates with a child" do
        expect(current.aggregate_sibling(other).reduce).to be_nil
      end

    end

  end

  describe Hn::Rollup::Value::Boolean do

    it 'creates a boolean value' do
      expect(Hn::Rollup::Value::Boolean.new(true)).to be_a Hn::Rollup::Value::Boolean
      expect(Hn::Rollup::Value::Boolean.new(false)).to be_a Hn::Rollup::Value::Boolean
      expect(Hn::Rollup::Value::Boolean.new({ 'boolean' => true })).to be_a Hn::Rollup::Value::Boolean
      expect(Hn::Rollup::Value::Boolean.new({ 'boolean' => false })).to be_a Hn::Rollup::Value::Boolean
    end

    it 'rejects an invalid value' do
      expect { Hn::Rollup::Value::Boolean.new('true') }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Boolean.new({ 'boolean' => nil }) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Boolean.new({ 'non-boolean' => true }) }.to raise_error(Hn::Rollup::Error)
    end

    context 'with valid value' do

      let(:true_value) { Hn::Rollup::Value::Boolean.new({ 'boolean' => true }) }
      let(:false_value) { Hn::Rollup::Value::Boolean.new({ 'boolean' => false }) }

      it "produces a valid value" do
        expect(true_value.reduce).to be true
        expect(false_value.reduce).to be false
        expect(true_value.canonical).to eq({ 'boolean' => true })
        expect(false_value.canonical).to eq({ 'boolean' => false })
      end

      it "aggregates with a sibling" do
        expect(true_value.aggregate_sibling(false_value).reduce).to be_nil
        expect(false_value.aggregate_sibling(true_value).reduce).to be_nil
      end

      it "aggregates with a child" do
        expect(true_value.aggregate_sibling(false_value).reduce).to be_nil
        expect(false_value.aggregate_sibling(true_value).reduce).to be_nil
      end

    end

  end

  describe Hn::Rollup::Value::Number do

    it 'creates a number value' do
      expect(Hn::Rollup::Value::Number.new(9)).to be_a Hn::Rollup::Value::Number
      expect(Hn::Rollup::Value::Number.new(5.7)).to be_a Hn::Rollup::Value::Number
      expect(Hn::Rollup::Value::Number.new({ 'number' => 9 })).to be_a Hn::Rollup::Value::Number
    end

    it 'rejects an invalid value' do
      expect { Hn::Rollup::Value::Number.new('5') }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Number.new({ 'number' => '5' }) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::Number.new({ 'non-number' => 9 }) }.to raise_error(Hn::Rollup::Error)
    end

    context 'with valid value' do

      let(:nine) { Hn::Rollup::Value::Number.new({ 'number' => 9 }) }
      let(:five_seven) { Hn::Rollup::Value::Number.new({ 'number' => 5.7 }) }

      it "produces a valid value" do
        expect(nine.reduce).to eq(9)
        expect(five_seven.reduce).to eq(5.7) # risky?
        expect(nine.canonical).to eq({ 'number' => 9 })
        expect(five_seven.canonical).to eq({ 'number' => 5.7 })
      end

      it "aggregates with a sibling" do
        expect(nine.aggregate_sibling(five_seven).reduce).to eq(14.7)
        expect(five_seven.aggregate_sibling(nine).reduce).to eq(14.7)
      end

      it "aggregates with a child" do
        expect(nine.aggregate_sibling(five_seven).reduce).to eq(14.7)
        expect(five_seven.aggregate_sibling(nine).reduce).to eq(14.7)
      end

    end

  end

  describe Hn::Rollup::Value::String do

    it 'creates a string value' do
      expect(Hn::Rollup::Value::String.new('foo')).to be_a Hn::Rollup::Value::String
      expect(Hn::Rollup::Value::String.new({ 'string' => 'foo' })).to be_a Hn::Rollup::Value::String
    end

    it 'rejects an invalid value' do
      expect { Hn::Rollup::Value::String.new(['string']) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::String.new(:string) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::String.new(9) }.to raise_error(Hn::Rollup::Error)
      expect { Hn::Rollup::Value::String.new({ 'non-string' => 'foo' }) }.to raise_error(Hn::Rollup::Error)
    end

    context 'with valid value' do

      let(:foo_value) { Hn::Rollup::Value::String.new({ 'string' => 'foo' }) }
      let(:bar_value) { Hn::Rollup::Value::String.new({ 'string' => 'bar' }) }

      it "produces a valid value" do
        expect(foo_value.reduce).to eq('foo')
        expect(bar_value.reduce).to eq('bar')
        expect(foo_value.canonical).to eq({ 'string' => 'foo' })
        expect(bar_value.canonical).to eq({ 'string' => 'bar' })
      end

      it "aggregates with a sibling" do
        expect(foo_value.aggregate_sibling(bar_value).reduce).to eq('foo')
        expect(bar_value.aggregate_sibling(foo_value).reduce).to eq('bar')
      end

      it "aggregates with a child" do
        expect(foo_value.aggregate_sibling(bar_value).reduce).to eq('foo')
        expect(bar_value.aggregate_sibling(foo_value).reduce).to eq('bar')
      end

    end

  end

end



















