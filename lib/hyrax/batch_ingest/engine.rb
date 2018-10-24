# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class Engine < ::Rails::Engine
      isolate_namespace Hyrax::BatchIngest
    end
  end
end
