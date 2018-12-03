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
          deposit_admin_sets = Hyrax::Collections::PermissionsService.source_ids_for_deposit(ability: self, source_type: 'admin_set')
          if deposit_admin_sets.present?
            # user who can deposit into at least one admin set can initiate a new batch
            can :new, Hyrax::BatchIngest::Batch
            # user who can deposit into an admin set can create batch for the admin set
            can :create, Hyrax::BatchIngest::Batch, admin_set_id: deposit_admin_sets
            # depositor of a batch can only show their batch
            can :read, Hyrax::BatchIngest::Batch, submitter_email: current_user.email
            # manager of a admin set (i.e. who can update the admin set) can show any batch for that admin set
            can :read, Hyrax::BatchIngest::Batch, admin_set_id: Hyrax::Collections::PermissionsService.source_ids_for_manage(ability: self, source_type: 'admin_set')
          end
        end
      end
    end
  end
end
