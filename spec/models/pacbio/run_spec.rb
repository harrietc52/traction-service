require 'rails_helper'

RSpec.describe Pacbio::Run, type: :model, pacbio: true do

  it 'must have a name' do
    expect(build(:pacbio_run, name: nil)).to_not be_valid
  end

  it 'must have a template prep kit box barcode' do
    expect(build(:pacbio_run, template_prep_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a binding kit box barcode' do
    expect(build(:pacbio_run, binding_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a sequencing kit box barcode' do
    expect(build(:pacbio_run, sequencing_kit_box_barcode: nil)).to_not be_valid
  end

  it 'must have a DNA control complex kit box barcode' do
    expect(build(:pacbio_run, dna_control_complex_box_barcode: nil)).to_not be_valid
  end

  it 'will have a uuid after creation' do
    expect(create(:pacbio_run).uuid).to be_present
  end

  it 'must have a system_name default' do
    expect(create(:pacbio_run).system_name).to eq 'Sequel II'
  end

  it 'can have a plate' do
    plate = create(:pacbio_plate)
    run = create(:pacbio_run, plate: plate)
    expect(run.plate).to eq(plate)
  end

  it 'can have some wells' do
    wells = create_list(:pacbio_well, 5)
    plate = create(:pacbio_plate, wells: wells)
    run = create(:pacbio_run, plate: plate)
    expect(run.wells.count).to eq(5)
  end

  it 'can have run comments ' do
    run = create(:pacbio_run)
    expect(run.comments).to eq("A Run Comment")
  end

  it 'can have the wells summary when no run comments exist' do
    wells = create_list(:pacbio_well_with_libraries, 2)
    plate = create(:pacbio_plate, wells: wells)
    run = create(:pacbio_run, plate: plate, comments: nil)
    expect(run.comments).to eq("#{wells.first.summary},#{wells[1].summary}")
  end

  context '#generate_sample_sheet' do
    after(:all) { File.delete('sample_sheet.csv') if File.exists?('sample_sheet.csv') }

    it 'must call CSVGenerator' do
      well1 = create(:pacbio_well_with_libraries, sequencing_mode: 'CCS')
      well2 = create(:pacbio_well_with_libraries, sequencing_mode: 'CLR')

      plate = create(:pacbio_plate, wells: [well1, well2])
      run = create(:pacbio_run, plate: plate)

      expect_any_instance_of(::CSVGenerator).to receive(:generate_sample_sheet)
      run.generate_sample_sheet
    end

    it 'must return a String' do
      well1 = create(:pacbio_well_with_libraries, sequencing_mode: 'CCS')
      well2 = create(:pacbio_well_with_libraries, sequencing_mode: 'CLR')

      plate = create(:pacbio_plate, wells: [well1, well2])
      run = create(:pacbio_run, plate: plate)

      sample_sheet = run.generate_sample_sheet
      expect(sample_sheet.class).to eq String
    end
  end

  context 'state' do
    it 'is pending by default' do
      run = create(:pacbio_run)
      expect(run).to be_pending
    end

    it 'can change the state to pending' do
      run = create(:pacbio_run)
      run.pending!
      expect(run).to be_pending
    end

    it 'can change the state to started' do
      run = create(:pacbio_run)
      run.started!
      expect(run).to be_started
    end

    it 'can change the state to completed' do
      run = create(:pacbio_run)
      run.completed!
      expect(run).to be_completed
    end

    it 'can change the state to cancelled' do
      run = create(:pacbio_run)
      run.cancelled!
      expect(run).to be_cancelled
    end

    it 'can filter runs based on state' do
      create_list(:pacbio_run, 2)
      create(:pacbio_run, state: :started)
      expect(Pacbio::Run.pending.length).to eq 2
      expect(Pacbio::Run.started.length).to eq 1
    end
  end

  context 'scope' do
    context 'active' do
      it 'should return only active runs' do
        create_list(:pacbio_run, 2)
        run = create(:pacbio_run, deactivated_at: DateTime.now)
        expect(Pacbio::Run.active.length).to eq 2
      end
    end
  end

end
