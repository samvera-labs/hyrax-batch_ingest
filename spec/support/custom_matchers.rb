# frozen_string_literal: true
module CustomMatchers
  def have_header(text)
    have_css 'h1', text: text
  end
end

RSpec.configure { |c| c.include CustomMatchers }
