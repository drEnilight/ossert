# frozen_string_literal: true

describe 'Ossert::Classifiers::Cluster' do
  let(:projectE) { Ossert::Project.load_by_name(@e_project) }
  let(:cluster_classifier) { Ossert::Classifiers::Cluster.current }
  let(:cluster_ref_values) { cluster_classifier.reference_values_per_grade }

  before do
    Ossert::Classifiers::Cluster.train_all_sections_thresholds
    cluster_classifier.train
  end

  it { expect(cluster_ref_values[:agility_total]['pr_closed_percent'].keys).to eq(Ossert::Classifiers::GRADES) }
  it { expect(projectE.grade_by_cluster).to eq(popularity: 'E', maintenance: 'E', maturity: 'E') }
end
