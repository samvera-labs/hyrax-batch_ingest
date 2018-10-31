# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchesController < Hyrax::BatchIngest::ApplicationController
      skip_authorize_resource
      def index
        @batches = Batch.all
      end

      def show
        @batch = Batch.find(params[:id])
      end
    end
  end
end
