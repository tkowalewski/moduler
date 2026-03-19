module Moduler
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
