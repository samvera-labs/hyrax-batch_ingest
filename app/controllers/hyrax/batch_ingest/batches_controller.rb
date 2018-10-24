# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchesController < Hyrax::BatchIngest::ApplicationController
      skip_authorize_resource

      def new
        # We need to have some batch ingest types before we proceed.
        if Hyrax::BatchIngest.config.ingest_types.empty?
          flash[:notice] = "No batch ingest types have been configured."
          redirect_back fallback_location: batches_url
        end
        @presenter = Hyrax::BatchIngest::BatchPresenter.new(Batch.new)
        @admin_sets = available_admin_sets
        @ingest_types = available_ingest_types
      end

      def create
        @batch = Batch.new(strong_params)
        if @batch.save
          flash[:notice] = 'Batch Started'
          redirect_to @batch
        else
          @presenter = presenter_for :new, @batch
          render :new
        end
      end

      def index
        # TODO: Restrict batches to those to which current_user is authorized
        @presenters = Batch.all.map do |batch|
          Hyrax::BatchIngest::BatchPresenter.new(batch)
        end
        @batches = Batch.all
      end

      def show
        @presenter = Hyrax::BatchIngest::BatchPresenter.new(Batch.find(strong_params[:id]))
      end

      private

        def available_admin_sets
          # TODO: Restrict available_admin_sets to only those current user has
          # access to.
          @available_admin_sets ||= AdminSet.all.map do |admin_set|
            [admin_set.title.first, admin_set.id]
          end
        end

        def available_ingest_types
          Hyrax::BatchIngest.config.ingest_types.map do |ingest_type, config|
            [config.label, ingest_type]
          end
        end

        def strong_params
          params.permit(:id, :submitter_email)
        end
    end
  end
end
