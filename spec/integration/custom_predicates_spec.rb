RSpec.describe Dry::Validation do
  subject(:validation) { schema.new }

  describe 'defining schema with custom predicates' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.predicates = Test::Predicates.import(Dry::Validation::Predicates)
        end

        key(:email) { |value| value.filled? & value.email? }
      end
    end

    before do
      module Test
        module Predicates
          extend Dry::Validation::PredicateSet

          predicate(:email?) do |input|
            input.include?('@') # for the lols
          end
        end
      end
    end

    it 'uses provided custom predicates' do
      expect(validation.(email: 'jane@doe')).to be_empty

      expect(validation.(email: nil)).to match_array([
        [:error, [:input, [:email, nil, [:rule, [:email, [:predicate, [:filled?, []]]]]]]]
      ])

      expect(validation.(email: 'jane')).to match_array([
        [:error, [:input, [:email, 'jane', [:rule, [:email, [:predicate, [:email?, []]]]]]]]
      ])
    end
  end
end