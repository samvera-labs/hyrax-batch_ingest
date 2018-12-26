# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::BatchIngest

      # # TODO: #74 the following causes undefined method error hyrax.batches_path
      # config.after_initialize do
      #   paths = ActionController::Base.view_paths.collect{|p| p.to_s}
      #   paths = paths.insert(paths.index(Hyrax::Engine.root.to_s + '/app/views'), Hyrax::BatchIngest::Engine.root.to_s + '/app/views')
      #   ActionController::Base.view_paths = paths
      # end
    end
  end
end
