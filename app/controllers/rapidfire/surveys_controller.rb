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

    def export
      @objects = if params[:id]
                 [Rapidfire::Survey.find(params[:id])]
               else
                 Rapidfire::Survey.all
               end

      respond_to do |format|
        format.html{}
      end
    end

  def import
  end

  def create_import
    data   = params.require("import")["data"].to_s
    survey  = YAML.load(data)
    questions=survey.delete(:questions)
    survey = Rapidfire::Survey.create(survey)
    survey.questions << Rapidfire::Question.create(questions)
    survey.save
    if survey.errors.empty?
      flash[:success] = action_cms("success", "Survey imported successfully.")
      respond_to do |format|
        format.html { redirect_to({ action: :index }) }
      end
    else
      flash[:alert] = action_cms("invalid", errors: survey.errors.full_messages.join("|")) {"Could not import survey. %{errors}"}
      respond_to do |format|
        format.html { redirect_to({ action: :import }) }
      end
    end
  end

  def reload_from_source
    @survey = Survey.find(params[:id])
    definition_file = @survey.definition_file

    file_path = Pyr.root.join(definition_file[1, definition_file.length])

    begin
      r = Survey.import(YAML.load_file(file_path), filepath: definition_file, overwrite: true)
      if r && (r.definition_file.blank? || r.definition_file != definition_file)
        r.definition_file = definition_file
        r.save!
      end
    rescue => e
      Rails.logger.error "Error reloading survey definition file #{definition_file} of Survey[#{r.try(:id)}] - #{r.try(:name)}  :  #{e.message}"
      Rails.logger.error e&.backtrace || e&.to_s
    end

    redirect_to r
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
