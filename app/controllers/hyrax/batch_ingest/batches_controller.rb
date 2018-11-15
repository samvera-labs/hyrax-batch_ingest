# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchesController < Hyrax::BatchIngest::ApplicationController
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
        @batch = Batch.new(batch_params)
        # TODO: Is the original_filename is what we really want to put
        # in source_location?
        @batch.source_location = params['batch']['batch_source'].original_filename
        # TODO: status should only be set to 'accepted' after validation of all
        # other fields succeeds.
        @batch.status = 'accepted'
        # TODO: Use BatchRunner to kick off the ingest process.
        if @batch.save
          flash[:notice] = 'Batch Started'
          redirect_to @batch
        else
          @presenter = Hyrax::BatchIngest::BatchPresenter.new(@batch)
          render :new
        end
      end

      def index
        @default_sort = 'created_at desc'
        # TODO: Restrict batches to those to which current_user is authorized
        @batches = Batch.all
                        .joins(:batch_items)
                        .group(:batch_id)
                        .order(sanitize_order(params[:order]))
                        .page(params[:page])
                        .per(params[:per])
        @presenters = @batches.map do |batch|
          Hyrax::BatchIngest::BatchPresenter.new(batch)
        end
      end

      def show
        @default_sort = 'id_within_batch asc'
        @batch = Batch.find(params[:id])
        @batch_items = @batch.batch_items
                             .order(sanitize_order(params[:order]))
                             .page(params[:page])
                             .per(params[:per])
        @presenter = Hyrax::BatchIngest::BatchPresenter.new(@batch)
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

        def batch_params
          params.require(:batch).permit(:submitter_email, :ingest_type, :admin_set_id)
        end

        # Avoid SQL injection attack on ActiveRecord order method
        # Input must be in format "column asc" or "column desc"
        def sanitize_order(order_param)
          order_param ||= @default_sort
          field, sort_direction = order_param.split
          sort_function = {
            'batch_item_count' => "count(batch_id) #{sort_direction}"
          }
          sort_function[field] || { field => sort_direction }
        end
    end
  end
end
