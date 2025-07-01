module Api
  module V1
    class LanguageLearningController < ApplicationController
      before_action :authenticate_user!

      # POST /api/v1/language_learning/translate_word
      def translate_word
        service = LanguageLearning::WordProcessor.call(
          word_params[:word],
          word_params[:source_language] || 'ukrainian',
          word_params[:target_languages] || %w[english polish],
          context: word_params[:context]
        )

        if service.success?
          render_success_response(
            word: service.word,
            source_language: service.source_language,
            target_languages: service.target_languages,
            context: service.context,
            translations: service.translations,
            examples: service.examples,
            word_info: service.word_info,
            processing_stats: service.processing_results[:processing_stats]
          )
        else
          render_error_response(service.errors, word: service.word)
        end
      end

      # POST /api/v1/language_learning/create_word_task
      def create_word_task
        project = current_user.projects.find(task_creation_params[:project_id])

        # Process the word first
        word_processor = LanguageLearning::WordProcessor.call(
          task_creation_params[:word],
          project.source_language,
          project.target_languages_array,
          context: project.learning_context
        )

        return render_error_response(word_processor.errors) unless word_processor.success?

        # Create task with processed data
        task_data = word_processor.create_task_data
        task = project.tasks.build(task_data)

        if task.save
          render_success_response(
            {
              task: TaskSerializer.new(task),
              processing_results: word_processor.processing_results
            },
            status: :created
          )
        else
          render_error_response(task.errors.full_messages)
        end
      end

      # GET /api/v1/language_learning/word_details/:task_id
      def word_details
        task = find_user_task(params[:id])

        return render_error_response([ 'Task is not a word translation task' ]) unless task.word_translation_task?

        render_success_response(
          task: TaskSerializer.new(task),
          original_word: task.original_word,
          translations: task.translations_hash,
          examples: task.examples_hash,
          learning_progress: task.learning_progress_percentage,
          can_advance: task.can_advance_learning?,
          project_context: build_project_context(task.project)
        )
      end

      # PATCH /api/v1/language_learning/advance_learning/:task_id
      def advance_learning
        task = find_user_task(params[:id])

        return render_error_response([ 'Task is not a word translation task' ]) unless task.word_translation_task?
        return render_error_response([ 'Task learning status cannot be advanced further' ]) unless task.can_advance_learning?

        old_status = task.learning_status
        task.advance_learning_status!

        if task.save
          render_success_response(
            task: TaskSerializer.new(task),
            status_change: {
              from: old_status,
              to: task.learning_status
            },
            learning_progress: task.learning_progress_percentage
          )
        else
          render_error_response(task.errors.full_messages)
        end
      end

      private

      def word_params
        params.require(:language_learning).permit(:word, :source_language, :context, target_languages: [])
      end

      def task_creation_params
        params.require(:language_learning).permit(:word, :project_id)
      end

      def find_user_task(task_id)
        Task.joins(:project).where(projects: { user: current_user }).find(task_id)
      end

      def build_project_context(project)
        {
          name: project.name,
          language_pair: project.language_pair_name,
          learning_context: project.learning_context
        }
      end

      def render_success_response(data, status: :ok)
        render json: {
          success: true,
          data: data
        }, status: status
      end

      def render_error_response(errors, additional_data = {}, status: :unprocessable_entity)
        render json: {
          success: false,
          errors: Array(errors)
        }.merge(additional_data), status: status
      end
    end
  end
end
