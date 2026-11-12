module Moduler
  # Sidebar resource visible to members whose role grants tasks.write.
  class ProjectsController < ApplicationController
    include OrganizationScoped

    def index
      redirect_to moduler.root_path, alert: t("moduler.flash.not_authorized") unless can?("tasks.write")
    end
  end
end
