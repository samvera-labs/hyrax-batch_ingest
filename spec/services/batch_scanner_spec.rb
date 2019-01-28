# Copyright 2011-2018, The Trustees of Indiana University and Northwestern
# University. Additional copyright may be held by others, as reflected in
# the commit history.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ---  END LICENSE_HEADER BLOCK  ---

# frozen_string_literal: true
require 'rails_helper'
require 'hyrax/batch_ingest/spec/shared_specs'

describe Hyrax::BatchIngest::BatchScanner do
  # before(:all) do
  #   class ExampleScanner < Hyrax::BatchIngest::BatchScanner
  #     protected
  #
  #     def unprocessed_manifests
  #       manifests
  #     end
  #   end
  # end

  # after(:all) do
  #   Object.send(:remove_const, :ExampleScanner)
  # end

  # let(:scanner_class) { ExampleScanner }
  let(:admin_set) { AdminSet.new }
  # let(:manifests) {[]}

  context 'when there are unprocessed manifests' do
    before do
      class ExampleScanner1 < Hyrax::BatchIngest::BatchScanner
        protected

        def unprocessed_manifests
          ['/dropbox/TestAdminSet/manifest1.csv', '/dropbox/TestAdminSet/manifest2.csv']
        end
      end
      # allow(admin_set).to receive(:id).and_return(0)
    end

    after do
      Object.send(:remove_const, :ExampleScanner1)
    end

    let(:scanner_class) { ExampleScanner1 }
    let(:manifests) {['/dropbox/TestAdminSet/manifest1.csv', '/dropbox/TestAdminSet/manifest2.csv']}
    it_behaves_like 'a Hyrax::BatchIngest::BatchScanner'
  end

  context 'when there is no unprocessed manifest' do
    before do
      class ExampleScanner2 < Hyrax::BatchIngest::BatchScanner
        protected

        def unprocessed_manifests
          []
        end
      end
    end

    after do
      Object.send(:remove_const, :ExampleScanner2)
    end

    let(:scanner_class) { ExampleScanner2 }
    let(:manifests) { [] }
    it_behaves_like 'a Hyrax::BatchIngest::BatchScanner'
  end
end
