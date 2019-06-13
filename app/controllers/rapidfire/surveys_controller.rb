module Rapidfire
  class SurveysController < Rapidfire::ApplicationController
    if Rails::VERSION::MAJOR == 5
      before_action :authenticate_administrator!, except: :index
    else
      before_filter :authenticate_administrator!, except: :index
    end

    def index
      @surveys = if defined?(Kaminari)
        Survey.page(params[:page])
      else
        Survey.all
      end
    end

    def new
      @survey = Survey.new
    end

    def create
      @survey = Survey.new(survey_params)
      if @survey.save
        respond_to do |format|
          format.html { redirect_to surveys_path }
          format.js
        end
      else
        respond_to do |format|
          format.html { render :new }
          format.js
        end
      end
    end

    def destroy
      @survey = Survey.find(params[:id])
      @survey.destroy

      respond_to do |format|
        format.html { redirect_to surveys_path }
        format.js
      end
    end

    def results
      @survey = Survey.find(params[:id])
      @survey_results =
        SurveyResults.new(survey: @survey).extract

      respond_to do |format|
        format.json { render json: @survey_results, root: false }
        format.html
        format.js
      end
    end

    def clone_modal
      @survey = Survey.find(params[:id])
    end

    def clone
      orig_survey = Survey.find(params[:id])
      Rails.logger.info("Original survey attributes in clone: #{orig_survey.attributes}")
      @survey = Survey.new(orig_survey.attributes)
      @survey.id = BSON::ObjectId.new
      @survey.assign_attributes(survey_params)
      Rails.logger.info("survey_params in clone: #{survey_params}")
      Rails.logger.info("Attributes after assign: #{@survey.attributes}")

      respond_to do |format|
        if @survey.save
          flash[:notice] = "survey_params.cloned_successsfully".cms{'Survey was successfully cloned.'}
          format.js {
            render js: "window.location.href='#{surveys_path(@survey)}', toastr.success('#{flash[:notice]}');"
          }
        else
          errors = @survey.errors.full_messages.join("<br/>")
          flash.now[:alert] = errors
          @orig_survey_id = params[:id]
          format.js { render "clone_modal" }
        end
      end
    end

    private

    def survey_params
      if Rails::VERSION::MAJOR >= 4
        params.require(:survey).permit(:name, :introduction)
      else
        params[:survey]
      end
    end
  end
end
