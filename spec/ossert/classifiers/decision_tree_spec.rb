# frozen_string_literal: true

require 'spec_helper'

describe 'Ossert::Classifiers::DecisionTree' do
  let(:projectE) { Ossert::Project.load_by_name(@e_project) }

  before { Ossert::Classifiers.train }

  it do
    expect(projectE.analyze_by_decisision_tree).to eq(
      agility: { total: 'ClassE', last_year: 'ClassE' },
      community: { total: 'ClassE', last_year: 'ClassE' }
    )
  end
end
