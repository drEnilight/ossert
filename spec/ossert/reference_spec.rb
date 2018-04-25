# frozen_string_literal: true

require 'spec_helper'

describe 'Ossert::Reference' do
  let(:projectB) { Ossert::Project.load_by_name(@b_project) }
  let(:reference) { Ossert::Reference::ClassB.new(20, [70]) }
  let(:last_ref_project) { Ossert::Project.load_by_name(reference.project_names.to_a.last) }

  before do
    VCR.use_cassette 'fetch_b_reference' do
      reference.prepare_projects!
      reference.project_names = Set.new(reference.project_names.to_a.last(1))
      reference.project_names << projectB.name

      Ossert::Reference.process_references(reference)
    end
  end

  it { expect(last_ref_project.reference).to eq 'ClassB' }
end
