RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe 'associations' do
    it { is_expected.to belong_to(:project).counter_cache(true) }
  end

  describe 'validations' do
    let(:valid_statuses) { %w[not_started in_progress completed] }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }

    it 'validates that status is included in the allowed values' do
      valid_statuses.each do |valid_status|
        expect(build(:task, status: valid_status)).to be_valid
      end
    end

    context 'when status is not included in the allowed values' do
      subject { build(:task, status: nil) }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:status]).to include("can't be blank")
      end
    end
  end

  describe 'enums' do
    let(:expected_statuses) do {
      "not_started" => "not_started",
      "in_progress" => "in_progress",
      "completed" => "completed"
    } end

    it 'defines status as a string-based enum with correct values' do
      expect(described_class.statuses).to eq(expected_statuses)
    end
  end

  describe 'search functionality' do
    let(:user) { create(:user) }
    let(:project) { create(:project, user:) }
    let!(:task) { create(:task,
      name: 'Test Name',
      description: 'Test Description with enough characters to meet the minimum length requirement',
      project: project,
      status: 'not_started') }

    before do
      Task.create_index!
      Task.import_data
      sleep 1
    end

    it_behaves_like 'searchable model', Task, { name: :name, description: :description }
    it_behaves_like 'model search settings', Task, 'tasks', %w[name description status project_id]

    describe 'indexed json' do
      it 'includes the correct fields' do
        indexed_json = task.as_indexed_json
        expect(indexed_json).to include(
          name: task.name,
          description: task.description,
          status: task.status,
          project_id: task.project_id,
          created_at: task.created_at
        )
      end
    end

    describe 'filtering' do
      it 'filters by project_id' do
        results = Task.search('Test', { project_id: project.id }).records
        expect(results.first.project_id).to eq(project.id)
      end

      it 'filters by status' do
        task.update(status: 'in_progress')
        Task.import_data
        sleep 1

        results = Task.search('Test', { status: 'in_progress' }).records
        expect(results.first.status).to eq('in_progress')
      end
    end
  end
end
