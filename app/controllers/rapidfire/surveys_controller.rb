module Rapidfire
  class SurveysController < Rapidfire::ApplicationController
    if Rails::VERSION::MAJOR == 5
      before_action :authenticate_administrator!, except: :index
    else
      before_filter :authenticate_administrator!, except: :index
    end

    def index
      if can_administer?
        @surveys = if defined?(Kaminari)
          Rapidfire::Survey.page(params[:page])
        else
          Rapidfire::Survey.all
        end
      else
        @surveys = if defined?(Kaminari)
          Rapidfire::Survey.joins(:attempts).where("rapidfire_attempts.user_id = ?", current_user.id).page(params[:page])
        else
          Rapidfire::Survey.joins(:attempts).where("rapidfire_attempts.user_id = ?", current_user.id).all
        end
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
