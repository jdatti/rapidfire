module Rapidfire
  class ApplicationController < PyrCore::PyrAdminController
    if Rapidfire.layout

      layout Rapidfire.layout
    end

    helper_method :can_administer?

    def authenticate_administrator!
      if can_administer?
        @admin_layout = true
      else
        raise Rapidfire::AccessDenied.new("cannot administer questions")
      end
    end

    # Override prefixes to consider the scoped.
    # for method current_user
    def scoped
      :user
    end
  end
end
