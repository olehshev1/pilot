RSpec.describe Tasks::Index do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let!(:tasks) { create_list(:task, 3, project: project) }

  describe '#call' do
    let(:service) { described_class.new(user, project) }

    subject { service.call }

    it 'returns all tasks for the project' do
      expect(subject.tasks.count).to eq(3)
      expect(subject.tasks).to match_array(project.tasks)
    end

    it 'includes the project association for each task' do
      subject.tasks.each do |task|
        expect(task.project).to eq(project)
      end
    end

    it 'returns success' do
      expect(subject.success?).to be_truthy
    end
  end
end
