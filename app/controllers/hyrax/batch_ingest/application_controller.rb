# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class ApplicationController < Hyrax::MyController
      # # TODO: #74 the following takes no effect
      # before_filter :set_view_path
      # def set_view_path
      #   prepend_view_path(Hyrax::BatchIngest::Engine.view_path)
      #   append_view_path Hyrax::BatchIngest::Engine.root.join('app', 'views', 'batch_ingest')
      # end

      protect_from_forgery with: :exception
    end
  end
end
