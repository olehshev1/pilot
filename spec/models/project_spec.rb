RSpec.describe Project, type: :model do
  subject { build(:project) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).counter_cache(true) }
    it { is_expected.to have_many(:tasks).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:source_language) }
    it { is_expected.to validate_inclusion_of(:source_language).in_array(Project::SUPPORTED_LANGUAGES) }

    # Name length validations
    it { is_expected.to validate_length_of(:name).is_at_least(5) }
    it { is_expected.to validate_length_of(:name).is_at_most(20) }

    # Description length validations
    it { is_expected.to validate_length_of(:description).is_at_least(20) }
    it { is_expected.to validate_length_of(:description).is_at_most(120) }

    context 'with invalid attributes' do
      it 'is invalid with a short name' do
        project = build(:project, name: 'a' * 4)
        expect(project).not_to be_valid
        expect(project.errors[:name]).to include('is too short (minimum is 5 characters)')
      end

      it 'is invalid with a long name' do
        project = build(:project, name: 'a' * 21)
        expect(project).not_to be_valid
        expect(project.errors[:name]).to include('is too long (maximum is 20 characters)')
      end

      it 'is invalid with a short description' do
        project = build(:project, description: 'a' * 19)
        expect(project).not_to be_valid
        expect(project.errors[:description]).to include('is too short (minimum is 20 characters)')
      end

      it 'is invalid with a long description' do
        project = build(:project, description: 'a' * 121)
        expect(project).not_to be_valid
        expect(project.errors[:description]).to include('is too long (maximum is 120 characters)')
      end

      it 'is invalid with unsupported source language' do
        project = build(:project, source_language: 'french')
        expect(project).not_to be_valid
        expect(project.errors[:source_language]).to include('is not included in the list')
      end
    end

    context 'with valid attributes' do
      it 'is valid with a name at minimum length' do
        project = build(:project, name: 'a' * 5)
        expect(project).to be_valid
      end

      it 'is valid with a name at maximum length' do
        project = build(:project, name: 'a' * 20)
        expect(project).to be_valid
      end

      it 'is valid with a description at minimum length' do
        project = build(:project, description: 'a' * 20)
        expect(project).to be_valid
      end

      it 'is valid with a description at maximum length' do
        project = build(:project, description: 'a' * 120)
        expect(project).to be_valid
      end

      it 'is valid with supported source language' do
        project = build(:project, source_language: 'ukrainian')
        expect(project).to be_valid
      end
    end
  end

  describe 'language learning functionality' do
    let(:project) { build(:project, source_language: 'ukrainian', target_languages: '["english", "polish"]') }

    describe '#target_languages_array' do
      it 'parses JSON target languages' do
        expect(project.target_languages_array).to eq(%w[english polish])
      end

      it 'returns default languages for blank target_languages' do
        project.target_languages = nil
        expect(project.target_languages_array).to eq(Project::DEFAULT_TARGET_LANGUAGES)
      end

      it 'returns default languages for invalid JSON' do
        project.target_languages = 'invalid json'
        expect(project.target_languages_array).to eq(Project::DEFAULT_TARGET_LANGUAGES)
      end
    end

    describe '#target_languages_array=' do
      it 'sets target languages as JSON' do
        project.target_languages_array = %w[english polish]
        expect(project.target_languages).to eq('["english","polish"]')
      end
    end

    describe '#learning_session?' do
      it 'returns true when source language and target languages are present' do
        expect(project.learning_session?).to be true
      end

      it 'returns false when source language is blank' do
        project.source_language = nil
        expect(project.learning_session?).to be false
      end

      it 'returns false when target languages are empty' do
        project.target_languages = '[]'
        expect(project.learning_session?).to be false
      end
    end

    describe '#supports_language?' do
      it 'returns true for supported languages' do
        expect(project.supports_language?('ukrainian')).to be true
        expect(project.supports_language?('english')).to be true
        expect(project.supports_language?('polish')).to be true
      end

      it 'returns false for unsupported languages' do
        expect(project.supports_language?('french')).to be false
      end

      it 'handles symbol input' do
        expect(project.supports_language?(:ukrainian)).to be true
        expect(project.supports_language?(:french)).to be false
      end
    end

    describe '#language_pair_name' do
      it 'returns formatted language pair for learning sessions' do
        expected = 'ukrainian → english, polish'
        expect(project.language_pair_name).to eq(expected)
      end

      it 'returns generic name for non-learning sessions' do
        project.source_language = nil
        expect(project.language_pair_name).to eq('General Project')
      end
    end
  end

  describe 'constants' do
    it 'defines supported languages' do
      expect(Project::SUPPORTED_LANGUAGES).to eq(%w[ukrainian english polish])
    end

    it 'defines default source language' do
      expect(Project::DEFAULT_SOURCE_LANGUAGE).to eq('ukrainian')
    end

    it 'defines default target languages' do
      expect(Project::DEFAULT_TARGET_LANGUAGES).to eq(%w[english polish])
    end
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

  describe 'deletion restrictions' do
    let!(:project) { create(:project) }

    context 'when project has tasks' do
      before { create(:task, project: project) }

      it 'cannot be deleted' do
        expect { project.destroy }.not_to change(Project, :count)
        expect(project.errors[:base]).to include("Cannot delete record because dependent tasks exist")
      end
    end

    context 'when project has no tasks' do
      it 'can be deleted' do
        expect { project.destroy }.to change(Project, :count).by(-1)
      end
    end
  end
end
