# frozen_string_literal: true
RSpec.shared_examples "a Hyrax::BatchIngest::BatchItemIngester" do
  before do
    raise 'ingester class must be set with `let(:ingester_class)`' unless defined? ingester_class
    raise 'batch item must be set with `let(:batch_item)`' unless defined? batch_item
  end

  subject { ingester }

  let(:ingester) { ingester_class.new(batch_item) }

  it { is_expected.to respond_to :ingest }
  it { is_expected.to respond_to :batch_item }

  describe '#initialize' do
    it 'stores the batch_item' do
      expect(ingester.batch_item).to eq batch_item
    end
  end

  describe '#ingest' do
    subject { ingester.ingest }

    it 'creates a new object' do
      expect { subject }.to change { ActiveFedora::Base.count }.by(1)
    end

    it 'returns a persisted object' do
      expect(subject).to be_an ActiveFedora::Base
      expect(subject).to be_persisted
      expect(subject.id).to be_present
    end
  end
end
