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
  before(:all) do
    class ExampleScanner < Hyrax::BatchIngest::BatchScanner
      protected

      def unprocessed_manifests
        manifests
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :ExampleScanner)
  end

  let(:scanner_class) { ExampleScanner }
  let(:admin_set) { AdminSet.new(title: ['TestAdminSet']) }

  context 'when there are unprocessed manifests' do
    let(:manifests) {['dropbox/manifest1.csv', 'dropbox/manifest2.csv']}
    it_behaves_like 'a Hyrax::BatchIngest::BatchScanner'
  end

  context 'when there is no unprocessed manifest' do
    let(:manifests) {[]}
    it_behaves_like 'a Hyrax::BatchIngest::BatchScanner'
  end
end
