# frozen_string_literal: true
module Hyrax
  module BatchIngest
    module Ability
      extend ActiveSupport::Concern
      included do
        self.ability_logic += [:batch_abilities]
      end

      # def user_abilities
      #   # ordinary user has no permission to act on batch
      # end

      # def depositor_abilities
      #   can [:create], Batch do |batch|
      #     Hyrax::Collections::PermissionsService.can_deposit_in_collection?(ability: self, collection_id: batch.admin_set_id)
      #   end
      # end

      # def manager_abilities
      #   return unless manager?
      #   can [:new, :create, :index, :show, :read, :edit, :update, :destroy], Hyrax::BatchIngest::Batch,
      # end

      def batch_abilities
        # # any logged in user can perform index on batch, although he may not have permission to see any existing batch (in which case nothing will be listed)
        # can [:index], Hyrax::BatchIngest::Batch

        if admin?
          # exclude edit/update since we don't have such actions, keep destroy since we allow cancelling of a batch job
          can [:new, :create, :index, :show, :read, :destroy], Hyrax::BatchIngest::Batch
        else
          # user who can deposit into an admin set can create batch against the admin set
          can [:new, :create], Hyrax::BatchIngest::Batch do |batch|
              can :deposit, AdminSet.find(batch.admin_set_id)
          end
          # can [:new, :create], Hyrax::BatchIngest::Batch do |batch|
          #   Hyrax::Collections::PermissionsService.can_deposit_in_collection?(ability: self, collection_id: batch.admin_set_id)
          # end

          # user who can show at least one admin set can view the batch index
          can [:index], Hyrax::BatchIngest::Batch if can :view_admin_show_any, AdminSet
          # can [:index], Hyrax::BatchIngest::Batch if Hyrax::Collections::PermissionsService.can_view_admin_show_for_any_admin_set?(ability: self)

          # manager of a admin set can show/cancel any batch for that admin set
          can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
            Hyrax::Collections::PermissionsService.manage_access_to_collection?(collection_id: batch.admin_set_id, ability: self)
          end
          # can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
          #   can :edit, AdminSet.find(batch.admin_set_id)
          # end

          # depositor of a batch can only show/cancel the batch created by himself
          can [:show, :destroy], Hyrax::BatchIngest::Batch do |batch|
            current_user == ::User.find_by(email: batch.submitter_email)
          end
        end
      end
    end
  end
end
