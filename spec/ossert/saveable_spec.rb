# frozen_string_literal: true

require 'spec_helper'

describe 'Ossert::Saveable' do
  let(:projectD) { Ossert::Project.load_by_name(@d_project) }
  let(:projectE) { Ossert::Project.load_by_name(@e_project) }

  let(:invalid_project) do
    projectE.github_alias = nil
    projectE
  end

  it { expect { invalid_project.dump }.to raise_error(Ossert::Saveable::RecordInvalid) }
  it { expect { projectD.dump_attribute(:tratata_data) }.to raise_error(KeyError) }
  it { expect { projectD.dump_attribute(:agility_total_data) }.not_to raise_error }
  it { expect { projectD.dump_attribute(:community_total_data) }.not_to raise_error }
  it { expect { projectD.dump_attribute(:agility_quarters_data) }.not_to raise_error }
  it { expect { projectD.dump_attribute(:community_quarters_data) }.not_to raise_error }
  it { expect(Ossert::Project.random_top.map(&:name)).to match_array([@a_project, @b_project, @c_project]) }
  it { expect { Ossert::Project.random }.not_to raise_error }
  it { expect(Ossert::Project.load_later_than(0)).not_to be_empty }

  context 'when NameException exists' do
    before { NameException.create(name: projectE.name, github_name: 'pow-wow/exception') }
    after { NameException.where(name: projectE.name).delete }

    it { expect(Ossert::Project.find_by_name(projectE.name).github_alias).to eq('pow-wow/exception') }
  end
end
