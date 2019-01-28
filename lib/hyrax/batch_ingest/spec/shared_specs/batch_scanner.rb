# frozen_string_literal: true
RSpec.shared_examples "a Hyrax::BatchIngest::BatchScanner" do
  before do
    raise 'scanner class must be set with `let(:scanner_class)`' unless defined? scanner_class
    raise 'admin_set must be set with `let(:admin_set)`' unless defined? admin_set
    raise 'manifests must be set with `let(:manifests)`' unless defined? manifests
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
    before do
      allow(admin_set).to receive(:id).and_return(0)
      allow(Hyrax::BatchIngest::BatchRunner).to receive(:new).and_call_original
      run_count = 0
      allow_any_instance_of(Hyrax::BatchIngest::BatchRunner).to receive(:run) { run_count += 1 }
      # manifests.each_with_index do |manifest, i|
      #   allow(Hyrax::BatchIngest::BatchRunner).to receive(:new).with(ingest_type: 'Avalon Ingest Type', source_location: manifest, admin_set_id: admin_set.id).and_return(runners[i])
      #   allow(runners[i]).to receive(:run)
      # end
    end

    # subject { scanner.scan }
    # let(:runners) { manifests.collect { |manifest| double('Hyrax::BatchIngest::BatchRunner') } }
    # let(:runners) { manifests.collect { Hyrax::BatchIngest::BatchRunner.new } }
    # let(:runners) { manifest.collect { |manifest| Hyrax::BatchIngest::BatchRunner.new(ingest_type: 'Avalon Ingest Type', source_location: manifest, admin_set_id: admin_set.id) } }

    it 'creates/run BatchRunner for each unprocessed manifest' do
      scanner.scan
      expect(Hyrax::BatchIngest::BatchRunner).to have_received(:new).exactly(manifests.count).times
      expect_any_instance_of(Hyrax::BatchIngest::BatchRunner).to have_received(:run).exactly(manifests.count).times
      # expect(run_count).to eq(manifests.count)
      manifests.each do |manifest|
        expect(Hyrax::BatchIngest::BatchRunner).to have_received(:new).with(ingest_type: 'Avalon Ingest Type', source_location: manifest, admin_set_id: admin_set.id)
      end
      # manifests.each_with_index do |manifest, i|
      #   expect(runners[i].to have_received(:run))
      # end
    end
  end
end
