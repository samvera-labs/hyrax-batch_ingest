# frozen_string_literal: true
module Hyrax
  module BatchIngest
    class ApplicationMailer < ActionMailer::Base
      # TODO: get default sender from config
      default from: 'admin@example.com'
      layout 'mailer'
    end
  end
end
