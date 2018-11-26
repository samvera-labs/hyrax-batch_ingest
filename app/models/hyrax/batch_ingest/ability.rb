# frozen_string_literal: true
module Hyrax
  module BatchIngest
    module Ability
      extend ActiveSupport::Concern
      included do
        self.ability_logic += [:admin_abilities]
      end

      def user_abilities
      end

      def admin_abilities
        # TODO: #27 where is admin? defined? what are the methods for other roles? should those be put here (rename method?) or create new methods?
        return unless admin?
        can [:create, :show, :index, :read, :edit, :update, :destroy], Hyrax::BatchIngest::Batch
      end
    end
  end
end