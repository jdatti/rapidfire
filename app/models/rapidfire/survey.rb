module Rapidfire
  class Survey < ActiveRecord::Base
    include Cms::CmsInstanceKeys
    sub_key :name
    sub_key :introduction
    
    has_many :attempts, class_name: Rapidfire::Attempt
    has_many  :questions
    validates :name, :presence => true

    if Rails::VERSION::MAJOR == 3
      attr_accessible :name, :introduction
    end

    def export
      export_hash =self.serializable_hash(except: [:id ,:created_at,:updated_at])
      export_hash.merge({questions: questions.map { |a| a.export }})

    end

    def self.import(data, filepath: nil, overwrite: false)
      
      name = data["name"]
      existing = Rapidfire::Survey.where(name: name).first
      
      if existing && !overwrite
        Rails.logger.info "\nDuplicate survey based on name [#{name}] and Description [#{description}]" 
        Rails.logger.info "Returning pre-existing Survey\n\n"
        return existing 
      end

      questions=data.delete(:questions)
      survey = Rapidfire::Survey.create(data)
      survey.questions << Rapidfire::Question.create(questions)
      survey.save!(validate: !(existing && overwrite))

      if existing && overwrite
        Rails.logger.warn "Overwriting existing Survey"
        existing.destroy  # only destroy after the new rule has been successfully saved!!!
      end
      survey
    end

    def attempted? user = nil
      if(user.present?)
        Rapidfire::Attempt.exists? survey: self, user: user
      else
        Rapidfire::Attempt.exists? survey: self
      end
    end
  end
end
