RSpec.describe HelloWorld do
  describe '#call' do
    subject { described_class.new(name:).call }

    let(:name) { 'John' }

    it 'returns a greeting with the given name' do
      is_expected.to eq "#{name}, Hello World!"
    end
  end
end
