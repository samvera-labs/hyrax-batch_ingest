# frozen_string_literal: true
RSpec.shared_examples "a Hyrax::BatchIngest::BatchReader" do
  before do
    raise 'reader class must be set with `let(:reader_class)`' unless defined? reader_class
    raise 'source location must be set with `let(:source_location)`' unless defined? source_location
    raise 'invalid source location must be set with `let(:invalid_source_location)`' unless defined? invalid_source_location
  end

  subject { reader }

  let(:reader) { reader_class.new(source_location) }
  let(:invalid_reader) { reader_class.new(invalid_source_location) }

  it { is_expected.to respond_to :submitter_email }
  it { is_expected.to respond_to :batch_items }
  it { is_expected.to respond_to :admin_set_id }
  it { is_expected.to respond_to :read }
  it { is_expected.to respond_to :been_read? }
  it { is_expected.to respond_to :source_location }

  describe '#initialize' do
    it 'stores the source_location' do
      expect(reader.source_location).to eq source_location
    end
  end

  describe '#batch_items' do
    subject { reader.batch_items }

    it 'returns an array of valid unpersisted batch items' do
      expect(subject).to be_an Array
      expect(subject).not_to be_empty
      subject.each do |item|
        expect(item).to be_a Hyrax::BatchIngest::BatchItem
        expect(item).not_to be_persisted
        expect(item.batch_id).to be_blank
        expect(item.id_within_batch).to be_present
        expect(item.status).to eq 'initialized'
        expect(item.source_data.present? || item.source_location.present?).to eq true
        expect(item.error).to be_blank
        expect(item.object_id).to be_blank
      end
    end

    context 'when unread' do
      it 'calls read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).to have_received(:read)
      end

      it 'sets the read flag' do
        expect { subject }.to change { reader.been_read? }.from(false).to(true)
      end
    end

    context 'when already read' do
      before do
        allow(reader).to receive(:been_read?).and_return(true)
      end

      it 'does not call read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).not_to have_received(:read)
      end
    end

    context 'with invalid source' do
      let(:reader) { invalid_reader }

      it 'raises a ReaderError' do
        expect { subject }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end
  end

  describe '#submitter_email' do
    subject { reader.submitter_email }

    context 'when unread' do
      it 'calls read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).to have_received(:read)
      end

      it 'sets the read flag' do
        expect { subject }.to change { reader.been_read? }.from(false).to(true)
      end
    end

    context 'when already read' do
      before do
        allow(reader).to receive(:been_read?).and_return(true)
      end

      it 'does not call read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).not_to have_received(:read)
      end
    end

    context 'with invalid source' do
      let(:reader) { invalid_reader }

      it 'raises a ReaderError' do
        expect { subject }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end
  end

  describe '#admin_set_id' do
    subject { reader.admin_set_id }

    context 'when unread' do
      it 'calls read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).to have_received(:read)
      end

      it 'sets the read flag' do
        expect { subject }.to change { reader.been_read? }.from(false).to(true)
      end
    end

    context 'when already read' do
      before do
        allow(reader).to receive(:been_read?).and_return(true)
      end

      it 'does not call read' do
        allow(reader).to receive(:read).and_call_original
        subject
        expect(reader).not_to have_received(:read)
      end
    end

    context 'with invalid source' do
      let(:reader) { invalid_reader }

      it 'raises a ReaderError' do
        expect { subject }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end
    end
  end

  describe '#been_read?' do
    subject { reader.been_read? }

    it 'initializes to false' do
      expect(subject).to eq false
    end

    it 'is true after calling read' do
      expect { reader.read }.to change { reader.been_read? }.from(false).to(true)
    end
  end

  describe '#read' do
    subject { reader.read }

    it 'sets the read flag' do
      expect { subject }.to change { reader.been_read? }.from(false).to(true)
    end

    context 'with invalid source' do
      let(:reader) { invalid_reader }

      it 'raises a ReaderError' do
        expect { subject }.to raise_error(Hyrax::BatchIngest::ReaderError)
      end

      it 'sets the read flag' do
        expect(reader.been_read?).to eq false
        expect { subject }.to raise_error(Hyrax::BatchIngest::ReaderError)
        expect(reader.been_read?).to eq true
      end
    end
  end
end
