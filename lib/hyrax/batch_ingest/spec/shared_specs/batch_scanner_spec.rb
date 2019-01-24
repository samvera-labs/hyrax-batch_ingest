# frozen_string_literal: true
RSpec.shared_examples "a Hyrax::BatchIngest::BatchScanner" do
  before do
    raise 'scanner class must be set with `let(:scanner_class)`' unless defined? scanner_class
    raise 'admin_set must be set with `let(:admin_set)`' unless defined? admin_set
  end

  subject { scanner }

  let(:scanner) { scanner_class.new(admin_set) }

  it { is_expected.to respond_to :admin_set }

  describe '#initialize' do
    it 'stores the admin_set' do
      expect(scanner.admin_set).to eq admin_set
    end
  end

  describe '#scan' do
    subject { scanner.scan }
    let(:manifests) { scanner.unprocessed_manifests }

    it 'creates/run BatchRunner for each unprocessed manifest' do
      expect(Hyrax::BatchIngest::BatchRunner).to have_received(:new).exactly(manifests.count).times
      expect(Hyrax::BatchIngest::BatchRunner).to have_received(:new).with(ingest_type: 'Avalon Ingest Type', admin_set_id: admin_set.id) if manifests.count > 0
    end
  end
end
