# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::BatchIngest

      # insert BatchIngest Engine view path after the app's view path and before Hyrax Engine view path
      config.after_initialize do
        paths = ActionController::Base.view_paths.collect(&:to_s)
        paths = paths.insert(paths.index(Hyrax::Engine.root.to_s + '/app/views'), Hyrax::BatchIngest::Engine.root.to_s + '/app/views')
        ActionController::Base.view_paths = paths
      end
    end
  end
end
