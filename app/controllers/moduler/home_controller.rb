module Moduler
  class HomeController < ApplicationController
    def index
      @memberships = Current.user.memberships.includes(:organization, :role).order("moduler_organizations.name")
    end
  end
end
