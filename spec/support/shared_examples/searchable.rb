RSpec.shared_examples 'searchable model' do |model_class, field_mapping|
  let(:model) { described_class }
  let(:search_term) { 'Test' }

  before do
    model_class.create_index!
    model_class.import_data
    sleep 1
  end

  field_mapping.each do |field, search_field|
    it "is searchable by #{field}" do
      results = model_class.search(search_term).records
      expect(results.first.public_send(search_field)).to include(search_term)
    end
  end

  it 'is searchable by partial match' do
    results = model_class.search(search_term).records
    expect(results.first.public_send(field_mapping.values.first)).to include(search_term)
  end

  it 'returns empty when no matches' do
    results = model_class.search('nonexistent').records
    expect(results).to be_empty
  end
end

RSpec.shared_examples 'model search settings' do |model_class, index_name, fields|
  it "uses correct index name for #{model_class}" do
    expect(model_class.index_name).to eq(index_name)
  end

  it "includes correct searchable fields for #{model_class}" do
    mapping = model_class.mappings.to_hash
    indexed_fields = mapping[:properties].keys.map(&:to_s)
    expect(indexed_fields).to match_array(fields)
  end
end
