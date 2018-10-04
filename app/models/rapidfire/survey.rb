module Rapidfire
  class Survey < ActiveRecord::Base
    has_many :attempts, class_name: Rapidfire::Attempt
    has_many  :questions
    validates :name, :presence => true

    if Rails::VERSION::MAJOR == 3
      attr_accessible :name, :introduction
    end
  end
end
