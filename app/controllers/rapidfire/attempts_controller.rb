module Rapidfire
  class AttemptsController < Rapidfire::ApplicationController
    if Rails::VERSION::MAJOR ==  5
      before_action :find_survey!
      before_action :check_resubmit_availability, only: [:create]
    else
      before_filter :find_survey!
      before_filter :check_resubmit_availability, only: [:create]
    end

    def new
      @attempt_builder = AttemptBuilder.new(attempt_params)
    end

    def create
      @attempt_builder = AttemptBuilder.new(attempt_params)
      if @attempt_builder.save
        previous_attempt =  Rapidfire::Attempt.find_by(user_id: current_user.id, survey_id: params[:survey_id], active: 1)
        previous_attempt.update(active: 0) if previous_attempt.present?

        @attempt_builder.attempt.update(active: 1)

        redirect_to after_answer_path_for
      else
        render :new
      end
    end

    def show
      @attempt_answers = Rapidfire::Answer.where(attempt_id: params[:id])
      @survey_questions = Rapidfire::Question.where(survey_id: params[:survey_id])
    end

    def edit
      @attempt_builder = AttemptBuilder.new(attempt_params)
    end

    def update
      @attempt_builder = AttemptBuilder.new(attempt_params)

      if @attempt_builder.save
        redirect_to surveys_path
      else
        render :edit
      end
    end

    private

    def check_resubmit_availability
      if PyrCore::AppSetting.enable_survey_resubmission != "true"
        respond_to do |format|
          format.js { render "rapidfire/attempts/submitted" }
        end
      end
    end

    def find_survey!
      @survey = Survey.find(params[:survey_id])
    end

    def attempt_params
      answer_params = { params: (params[:attempt] || {}) }
      answer_params.merge(user: current_user, survey: @survey, attempt_id: params[:id])
    end

    # Override path to redirect after answer the survey
    # Write:
    #   # my_app/app/decorators/controllers/rapidfire/answer_groups_controller_decorator.rb
    #   Rapidfire::AnswerGroupsController.class_eval do
    #     def after_answer_path_for
    #       main_app.root_path
    #     end
    #   end
    def after_answer_path_for
      surveys_path
    end

    def rapidfire_current_scoped
      send 'current_'+scoped.to_s
    end
  end
end
