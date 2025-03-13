RSpec.describe Projects::Index do
  let(:user) { create(:user) }
  let!(:projects) { create_list(:project, 3, user: user) }
  let(:other_user) { create(:user) }
  let!(:other_projects) { create_list(:project, 2, user: other_user) }

  describe '#call' do
    let(:service) { described_class.new(user) }
    let(:result) { service.call }

    it 'returns all projects for the user' do
      expect(result.projects.count).to eq(3)
      expect(result.projects).to match_array(projects)
    end

    it 'does not return other users\' projects' do
      expect(result.projects).not_to include(*other_projects)
    end

    it 'returns success' do
      expect(result.success?).to be_truthy
    end

    it 'includes associated records' do
      expect(result.projects.first.association(:user)).to be_loaded
      expect(result.projects.first.association(:tasks)).to be_loaded
    end
  end
end
