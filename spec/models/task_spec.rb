RSpec.describe Task, type: :model do
  subject { build(:task) }

  describe 'associations' do
    it { is_expected.to belong_to(:project).counter_cache(true) }
  end

  describe 'validations' do
    subject { described_class.new(name: "Test", description: "Test", status: nil) }

    let(:valid_statuses) { %w[not_started in_progress completed] }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:project_link) }

    it 'validates that status is included in the allowed values' do
      valid_statuses.each do |valid_status|
        expect(build(:task, status: valid_status)).to be_valid
      end
    end

    context 'when status is not included in the allowed values' do
      it 'validates task' do
        subject.valid?

        expect(subject.errors[:status]).to include("can't be blank")
      end
    end

    subject { build(:task, status: nil) }

    it "validates presence of status" do
      subject.valid?

      expect(subject.errors[:status]).to include("can't be blank")
    end

    context 'project_link validation' do
      let(:task) { build(:task, project_link: project_link) }

      context 'when project_link is a valid URL' do
        let(:project_link) { 'https://example.com' }

        it 'is valid' do
          expect(task).to be_valid
        end
      end

      context 'when project_link is not a valid URL' do
        let(:project_link) { 'not-a-url' }

        it 'is not valid' do
          expect(task).not_to be_valid
          expect(task.errors[:project_link]).to include('must be a valid URL')
        end
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
end
