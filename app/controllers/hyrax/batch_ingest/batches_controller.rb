# frozen_string_literal: true

module Hyrax
  module BatchIngest
    class BatchesController < Hyrax::BatchIngest::ApplicationController
      # following call is needed to enable action authorization
      load_and_authorize_resource

      def new
        # We need to have some batch ingest types before we proceed.
        if Hyrax::BatchIngest.config.ingest_types.empty?
          # TODO: Add a hint as to how/where to add ingest types to config.
          flash[:notice] = "No batch ingest types have been configured."
          redirect_back fallback_location: batches_url
        end
        @presenter = Hyrax::BatchIngest::BatchPresenter.new(@batch)
        @admin_sets = available_admin_sets
        @ingest_types = available_ingest_types
      end

      def create
        @batch.source_location = params['batch']['batch_source'].path
        @batch.status = 'received'

        if @batch.valid?
          # This will kick off jobs to process the batch.
          start_batch_runner(@batch)
          flash[:notice] = 'Batch Started'
          redirect_to @batch
        else
          @presenter = Hyrax::BatchIngest::BatchPresenter.new(@batch)
          render :new
        end
      end

      def index
        @default_sort = 'created_at desc'
        # Restrict batches to those to which current_user is authorized
        # via cancancan's load_resource (which uses accessible_by)
        @batches = @batches.left_joins(:batch_items)
                           .group(:batch_id, :id)
                           .order(sanitize_order(params[:order]))
                           .page(params[:page])
                           .per(params[:per])
        @presenters = @batches.map do |batch|
          Hyrax::BatchIngest::BatchPresenter.new(batch)
        end
      end

      def show
        @default_sort = 'id_within_batch asc'
        @batch_items = @batch.batch_items
                             .order(sanitize_order(params[:order]))
                             .page(params[:page])
                             .per(params[:per])
        @presenter = Hyrax::BatchIngest::BatchPresenter.new(@batch)
      end

      def summary
        @presenter = Hyrax::BatchIngest::BatchSummaryPresenter.new(@batch)
      end

      private

        def available_admin_sets
          # Restrict available_admin_sets to only those current user can desposit to.
          @available_admin_sets ||= Hyrax::Collections::PermissionsService.source_ids_for_deposit(ability: current_ability, source_type: 'admin_set').map do |admin_set_id|
            [AdminSet.find(admin_set_id).title.first, admin_set_id]
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

        def start_batch_runner(batch)
          Hyrax::BatchIngest::BatchRunner.new(batch: batch).run
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
