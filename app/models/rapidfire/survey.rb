module Rapidfire
  class Survey < ActiveRecord::Base
    has_many  :questions
    validates :name, :presence => true
    validates_uniqueness_of :name

    if Rails::VERSION::MAJOR == 3
      attr_accessible :name, :introduction
    end
  end
end
