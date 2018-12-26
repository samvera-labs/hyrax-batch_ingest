module Hyrax
  module BatchIngest
    class Hyrax::BatchIngest::DashboardController < Hyrax::DashboardController
      # # TODO: #74 the following takes no effect
      #
      # before_filter :set_view_path
      # def set_view_path
      #   prepend_view_path(Hyrax::BatchIngest::Engine.view_path)
      # end
      #
      # included do
      #   prepend_view_path(Hyrax::BatchIngest::Engine.view_path)
      # end
    end
  end
end