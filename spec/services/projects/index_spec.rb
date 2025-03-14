RSpec.describe Projects::Index do
  let(:user) { create(:user) }
  let!(:projects) { create_list(:project, 3, user: user) }
  let(:other_user) { create(:user) }
  let!(:other_projects) { create_list(:project, 2, user: other_user) }

  describe '#call' do
    context 'without filters' do
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

    context 'with task_status filter' do
      let!(:project_with_completed_task) { create(:project, user: user) }
      let!(:project_with_in_progress_task) { create(:project, user: user) }
      let!(:project_with_not_started_task) { create(:project, user: user) }

      before do
        create(:task, :completed, project: project_with_completed_task)
        create(:task, :in_progress, project: project_with_in_progress_task)
        create(:task, status: 'not_started', project: project_with_not_started_task)
      end

      it 'filters projects by completed tasks' do
        service = described_class.new(user, { task_status: 'completed' })
        result = service.call

        expect(result.projects).to include(project_with_completed_task)
        expect(result.projects).not_to include(project_with_in_progress_task)
        expect(result.projects).not_to include(project_with_not_started_task)
      end

      it 'filters projects by in_progress tasks' do
        service = described_class.new(user, { task_status: 'in_progress' })
        result = service.call

        expect(result.projects).not_to include(project_with_completed_task)
        expect(result.projects).to include(project_with_in_progress_task)
        expect(result.projects).not_to include(project_with_not_started_task)
      end

      it 'filters projects by not_started tasks' do
        service = described_class.new(user, { task_status: 'not_started' })
        result = service.call

        expect(result.projects).not_to include(project_with_completed_task)
        expect(result.projects).not_to include(project_with_in_progress_task)
        expect(result.projects).to include(project_with_not_started_task)
      end

      it 'maintains eager loading with filters' do
        service = described_class.new(user, { task_status: 'completed' })
        result = service.call

        expect(result.projects.first.association(:user)).to be_loaded
        expect(result.projects.first.association(:tasks)).to be_loaded
      end

      it 'returns empty result if no projects match the filter' do
        service = described_class.new(user, { task_status: 'non_existent_status' })
        result = service.call

        expect(result.projects).to be_empty
      end
    end
  end

  describe '#success?' do
    let(:service) { described_class.new(user) }

    it 'returns true when errors array is empty' do
      service.call
      expect(service.success?).to be_truthy
    end
  end

  describe 'caching' do
    let(:service) { described_class.new(user) }
    let(:cache_key) { service.send(:cache_key) }

    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    it 'uses Rails cache' do
      expect(Rails.cache).to receive(:fetch).with(String, hash_including(:expires_in))
      service.call
    end

    it 'builds unique cache key based on user and updated_at' do
      key = service.send(:cache_key)
      expect(key).to include(user.id.to_s)
      expect(key).to include(user.updated_at.to_s)
    end

    it 'builds unique cache key with task status when filtered' do
      service = described_class.new(user, { task_status: 'completed' })
      key = service.send(:cache_key)
      expect(key).to include('task_status:completed')
    end

    it 'returns cached results on subsequent calls' do
      cached_projects = double("projects")
      cache_key = service.send(:cache_key)

      expect(Rails.cache).to receive(:fetch).with(cache_key, hash_including(:expires_in)).and_yield
      expect(service).to receive(:fetch_projects).once.and_return(cached_projects)

      service.call

      allow(Rails.cache).to receive(:fetch).with(cache_key, hash_including(:expires_in))
                                           .and_return(cached_projects)

      service.call
    end

    it 'invalidates cache when user is updated' do
      service1 = described_class.new(user)

      first_key = service1.send(:cache_key)
      allow(Rails.cache).to receive(:fetch).with(any_args).and_call_original
      expect(Rails.cache).to receive(:fetch).with(first_key, hash_including(:expires_in))
      service1.call

      future_time = Time.now + 1.day
      user.update_column(:updated_at, future_time)

      service2 = described_class.new(user.reload)
      second_key = service2.send(:cache_key)

      expect(second_key).not_to eq(first_key)

      expect(Rails.cache).to receive(:fetch).with(second_key, hash_including(:expires_in))
      service2.call
    end
  end
end
