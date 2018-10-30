# frozen_string_literal: true
module Hyrax
  module BatchIngest
    module Ability
      extend ActiveSupport::Concern
      included do
        self.ability_logic += [:admin_abilities]
      end

      def admin_abilities
        return unless admin?
        can [:create, :show, :index, :read, :edit, :update, :destroy], Hyrax::BatchIngest::Batch
      end
    end
  end
end
