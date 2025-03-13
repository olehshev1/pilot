RSpec.describe Project, type: :model do
  subject { build(:project) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).counter_cache(true) }
    it { is_expected.to have_many(:tasks).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe 'task counts' do
    let!(:project) { create(:project) }

    context 'when tasks are added' do
      let!(:tasks) { create_list(:task, 3, project: project) }

      it 'keeps track of the tasks count' do
        expect(project.tasks.count).to eq(3)
      end
    end
  end
end
