module Hyrax
  module BatchIngest
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
