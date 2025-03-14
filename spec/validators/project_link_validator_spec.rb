RSpec.describe ProjectLinkValidator do
  describe '#validate' do
    let(:validator) { described_class.new }
    let(:task) { build(:task, project: create(:project)) }

    context 'when project_link is a valid URL' do
      it 'does not add any errors for http URL' do
        task.project_link = 'http://example.com'
        validator.validate(task)
        expect(task.errors[:project_link]).to be_empty
      end

      it 'does not add any errors for https URL' do
        task.project_link = 'https://example.com'
        validator.validate(task)
        expect(task.errors[:project_link]).to be_empty
      end
    end

    context 'when project_link is not a valid URL' do
      it 'adds an error for invalid URL format' do
        task.project_link = 'not-a-url'
        validator.validate(task)
        expect(task.errors[:project_link]).to include('must be a valid URL')
      end

      it 'adds an error for URL with invalid protocol' do
        task.project_link = 'ftp://example.com'
        validator.validate(task)
        expect(task.errors[:project_link]).to include('must be a valid URL')
      end
    end

    context 'when project_link is blank' do
      it 'does not add any errors and skips validation' do
        task.project_link = ''
        validator.validate(task)
        expect(task.errors[:project_link]).to be_empty
      end

      it 'does not add any errors for nil' do
        task.project_link = nil
        validator.validate(task)
        expect(task.errors[:project_link]).to be_empty
      end
    end
  end
end
