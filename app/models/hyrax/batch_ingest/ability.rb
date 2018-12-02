# frozen_string_literal: true
module Hyrax
  module BatchIngest
    module Ability
      extend ActiveSupport::Concern
      included do
        self.ability_logic += [:batch_abilities]
      end

      def batch_abilities
        if admin?
          # exclude edit/update since we don't have such actions, keep destroy since we allow cancelling of a batch job
          can [:new, :create, :index, :show, :read, :destroy], Hyrax::BatchIngest::Batch
        else
          # user who can deposit into at least one admin set can initiate a new batch
          can [:new], Hyrax::BatchIngest::Batch if Hyrax::Collections::PermissionsService.source_ids_for_deposit(ability: self, source_type: 'admin_set').present?

          # user who can deposit into an admin set can create batch for the admin set
          can [:create], Hyrax::BatchIngest::Batch do |batch|
            admin_set = batch.admin_set_id.present? ? AdminSet.find_by_id(batch.admin_set_id) : nil
            admin_set && (can? :deposit, admin_set)
          end
          # can [:create], Hyrax::BatchIngest::Batch do |batch|
          #   Hyrax::Collections::PermissionsService.can_deposit_in_collection?(ability: self, collection_id: batch.admin_set_id)
          # end

          # user who can view at least one admin set can access the batch index
          can [:index], Hyrax::BatchIngest::Batch if can? :view_admin_show_any, AdminSet
          # can [:index], Hyrax::BatchIngest::Batch if Hyrax::Collections::PermissionsService.can_view_admin_show_for_any_admin_set?(ability: self)

          # manager of a admin set (i.e. who can update the admin set) can show/cancel any batch for that admin set
          can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
            admin_set = batch.admin_set_id.present? ? AdminSet.find_by_id(batch.admin_set_id) : nil
            admin_set && (can? [:edit, :update, :destroy, :view_admin_show], admin_set)
          end
          # can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
          #   Hyrax::Collections::PermissionsService.manage_access_to_collection?(collection_id: batch.admin_set_id, ability: self)
          # end

          # depositor of a batch can only show/cancel the batch created by himself
          can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
            current_user.email == batch.submitter_email
          end
          # can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
          #   current_user == ::User.find_by(email: batch.submitter_email)
          # end
        end
      end
    end
  end
end
