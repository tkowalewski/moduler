module Moduler
  # Sidebar resource visible to every member of the organization.
  class ReportsController < ApplicationController
    include OrganizationScoped

    def index; end
  end
end
