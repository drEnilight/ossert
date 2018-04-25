# frozen_string_literal: true

require 'spec_helper'

describe Ossert do
  let(:projectA) { Ossert::Project.load_by_name(@a_project) }
  let(:projectB) { Ossert::Project.load_by_name(@b_project) }
  let(:projectC) { Ossert::Project.load_by_name(@c_project) }
  let(:projectD) { Ossert::Project.load_by_name(@d_project) }
  let(:projectE) { Ossert::Project.load_by_name(@e_project) }

  describe 'common behaviour' do
    let(:no_github_project) { Ossert::Project.load_by_name(@no_github_project) }
    let(:github_not_found_project) { Ossert::Project.load_by_name(@github_not_found_project) }

    it { expect(no_github_project).to be_without_github_data }
    it { expect(github_not_found_project).to be_without_github_data }

    let(:project_A_time_range) do
      [Date.parse('01/04/2010'), Date.parse('01/10/2016')]
    end

    it { expect(Ossert::Project.load_by_name('Not Exists')).to be_nil }
    it do
      expect(projectA.prepare_time_bounds!).to eq(project_A_time_range)
    end

    context 'when classifiers are ready' do
      before { Ossert::Classifiers.train }

      let(:grades_A) do
        { popularity: 'B', maintenance: 'C', maturity: 'C' }
      end
      let(:grades_B) do
        { popularity: 'A', maintenance: 'B', maturity: 'A' }
      end
      let(:grades_C) do
        { popularity: 'C', maintenance: 'B', maturity: 'B' }
      end
      let(:grades_D) do
        { popularity: 'D', maintenance: 'C', maturity: 'D' }
      end
      let(:grades_E) do
        { popularity: 'E', maintenance: 'D', maturity: 'E' }
      end

      it do
        expect(projectA.grade_by_classifier).to eq(grades_A)
        expect(projectB.grade_by_classifier).to eq(grades_B)
        expect(projectC.grade_by_classifier).to eq(grades_C)
        expect(projectD.grade_by_classifier).to eq(grades_D)
        expect(projectE.grade_by_classifier).to eq(grades_E)
      end

      context 'when non default last year offset' do
        it { expect(projectA.agility.quarters.last_year_as_hash(3)).to be_a_kind_of(Hash) }
        it { expect(projectA.agility.quarters.last_year_as_hash(5)).to be_a_kind_of(Hash) }
        it { expect(projectA.agility.quarters.last_year_data(3)).to be_a_kind_of(Array) }
        it { expect(projectA.agility.quarters.last_year_data(5)).to be_a_kind_of(Array) }
      end

      context 'when project is decorated' do
        let(:project) { projectE.decorated }
        let(:call_references) do
          project.preview_reference_values_for(metric_name, section)
        end

        describe '#tooltip_data' do
          let(:tooltip_data) { projectB.decorated.tooltip_data('issues_all_count') }

          it do
            expect(tooltip_data).to eq(
              description: 'Total number of issues, with any status',
              ranks: [{ type: 'a', quarter: '&gt;&nbsp; 1', total: '&gt;&nbsp; 92', year: '&gt;&nbsp; 8' },
                      # Strange behavior with B values higher then A. Do we need to change initial projects list?
                      { type: 'b', quarter: '&gt;&nbsp; 27', total: '&gt;&nbsp; 68', year: '&gt;&nbsp; 51' },
                      { type: 'c', quarter: '&gt;&nbsp; 4', total: '&gt;&nbsp; 19', year: '&gt;&nbsp; 14' },
                      { type: 'd', quarter: '&gt;&nbsp; 8', total: '&gt;&nbsp; 10', year: '&gt;&nbsp; 10' },
                      { type: 'e', quarter: '&gt;&nbsp; 0', total: '&gt;&nbsp; 2', year: '&gt;&nbsp; 2' }],
              title: 'Number of Issues'
            )
          end
        end

        describe '#metric_preview' do
          context 'when metric is life_period' do
            let(:preview) { project.metric_preview('life_period') }
            let(:other_preview) { projectB.decorated.metric_preview('life_period') }

            it do
              expect(preview[:total_mark]).to eq('e')
              expect(preview[:total_text]).to eq('Less than a year&nbsp;E')
              expect(preview[:total_val]).to eq(87_828.0)
              expect(other_preview[:total_mark]).to eq('b')
              expect(other_preview[:total_text]).to eq('2+ years&nbsp;B')
              expect(other_preview[:total_val]).to eq(75_673_089.0)
            end
          end

          context 'when metric is issues_processed_in_avg' do
            let(:preview) { project.metric_preview('issues_processed_in_avg') }

            it do
              expect(preview[:last_year_mark]).to eq('b')
              expect(preview[:last_year_text]).to eq('~1 month&nbsp;B')
              expect(preview[:last_year_val]).to eq(44.0)
              expect(preview[:total_mark]).to eq('b')
              expect(preview[:total_text]).to eq('~1 month&nbsp;B')
              expect(preview[:total_val]).to eq(44.0)
            end
          end

          context 'when metric is issues_processed_in_median' do
            let(:preview) { project.metric_preview('issues_processed_in_median') }

            it do
              expect(preview[:last_year_mark]).to eq('b')
              expect(preview[:last_year_text]).to eq('~1 month&nbsp;B')
              expect(preview[:last_year_val]).to eq(44.0)
              expect(preview[:total_mark]).to eq('b')
              expect(preview[:total_text]).to eq('~1 month&nbsp;B')
              expect(preview[:total_val]).to eq(44.0)
            end
          end
        end

        describe '#reference_values_per_grade' do
          context 'when agility_total metric given' do
            let(:section) { :agility_total }

            context 'when growing metric given' do
              let(:metric_name) { 'issues_all_count' }

              it do
                expect(call_references).to eq('A' => '> 92',
                                              'B' => '> 68',
                                              'C' => '> 19',
                                              'D' => '> 10',
                                              'E' => '> 2')
              end
            end

            context 'when lowering metric given' do
              let(:metric_name) { 'stale_branches_count' }

              it do
                expect(call_references).to eq('A' => '< 3',
                                              'B' => '< 6',
                                              'C' => '< 9',
                                              'D' => '< 12',
                                              'E' => '< 15')
              end
            end
          end
        end
      end
    end

    context 'when classifiers are not ready' do
      before { Ossert::Classifiers::Growing.all = nil }

      it do
        expect { projectA.grade_by_classifier }.to(
          raise_error(StandardError)
        )
      end
    end
  end

  describe 'Ossert::Workers::FetchBestgemsPage' do
    before { allow(Ossert::Project).to receive(:fetch_all) }
    before { allow(Ossert).to receive(:init) }

    describe 'ForkProcessing' do
      class SumInFork
        include Ossert::Workers::ForkProcessing

        attr_reader :result

        def initialize
          @result = nil
        end

        def sum(attr1, attr2)
          process_in_fork(force: true) { @result = attr1 + attr2 }
        end
      end
      # not working... need to figure out why
    end

    describe 'FetchBestgemsPage' do
      it do
        VCR.use_cassette 'fetch_bestgems_page' do
          Ossert::Workers::FetchBestgemsPage.new.perform(1)
        end
      end
    end

    describe 'Fetch' do
      it { Ossert::Workers::Fetch.new.perform('rack') }
    end

    describe 'PartialFetch' do
      it do
        VCR.use_cassette 'fetch_partial_rubygems' do
          Ossert::Workers::PartialFetch.new.perform('Rubygems', projectE.name)
        end
      end
    end

    describe 'PartialRefreshFetch' do
      it { Ossert::Workers::PartialRefreshFetch.new.perform('Bestgems') }
    end

    describe 'RefreshFetch' do
      it { Ossert::Workers::RefreshFetch.new.perform }
    end
  end

  describe 'Ossert::Fetch' do
    let(:project) { Ossert::Project.load_by_name(project_name) }
    let(:project_name) { projectD.name }

    before do
      VCR.use_cassette 'fetch_a_rubygems' do
        Ossert::Project.update_with_one_fetcher(Ossert::Fetch::Rubygems, project_name)
      end
    end

    it { expect(project.github_alias).to eq 'dry-rb/dry-web' }
  end
end
