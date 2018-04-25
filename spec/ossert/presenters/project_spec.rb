# frozen_string_literal: true

require 'spec_helper'

describe 'Ossert::Presenters::Project' do
  let(:projectB) { Ossert::Project.load_by_name(@b_project) }
  let(:projectC) { Ossert::Project.load_by_name(@c_project) }
  let(:decorated_project) { projectC.decorated }

  before { Ossert::Classifiers.train }

  it do
    expect(Ossert::Presenters::Project.preview_for(projectB)[:analysis]).to eq(
      popularity: 'a',
      maintenance: 'b',
      maturity: 'a'
    )
  end

  it do
    expect(decorated_project.agility_quarter(Time.parse('01.01.2016'))).to eq(
      'Average Issue Processing Time' => "  ~24 days&nbsp;A <> ~-58 months\n",
      'Average Pull Request Processing Time' => "  ~17 days&nbsp;A <> ~4 days\n",
      'Issues Closed, %' => "  70%&nbsp;C <> +70%\n",
      'Median Issue Processing Time' => "  ~1 day&nbsp;A <> ~-58 months\n",
      'Median Pull Request Processing Time' => "  ~16 days&nbsp;A <> ~1 day\n",
      'Number of Commits Made' => "  11&nbsp;A <> +4\n",
      'Number of Issues' => "  10&nbsp;A <> +8\n",
      'Number of Legacy Issues' => "  2&nbsp;A <> +1\n",
      'Number of Legacy Pull Requests' => "  3&nbsp;A <> +3\n",
      'Number of Pull Requests' => "  13&nbsp;A <> +7\n",
      'Number of Releases' => "  1&nbsp;A <> +1\n",
      'Pull Requests Closed, %' => "  70%&nbsp;C <> +19%\n"
    )
  end
  it do
    expect(decorated_project.community_quarter(Time.parse('01.01.2016'))).to eq(
      'Average Number of Answers' => "  0&nbsp;E <> 0\n",
      'Median Questioner Reputation' => "  0&nbsp;E <> 0\n",
      'Number of Downloads' => "  15,435&nbsp;D <> +10,981\n",
      'Number of Forks' => "  51&nbsp;A <> +43\n",
      'Number of Stargazers' => "  2013&nbsp;A <> +1536\n",
      'Number of Total Users Involved' => "  2063&nbsp;A <> +1575\n",
      'Number of Users Commenting Issues' => "  7&nbsp;A <> +6\n",
      'Number of Users Commenting Pull Requests' => "  19&nbsp;A <> +13\n",
      'Number of Users Creating Issues' => "  6&nbsp;A <> +5\n",
      'Number of Users Creating Pull Requests' => "  5&nbsp;A <> 0\n",
      'Number of Users Involved without Stargazers' => "  50&nbsp;A <> +39\n",
      'Number of Questioners' => "  0&nbsp;D <> 0\n",
      'Number of Questions' => "  0&nbsp;C <> 0\n",
      'Resolved Questions, %' => "  0%&nbsp;A <> 0%\n",
      'Sum of Question Scores' => "  0&nbsp;E <> 0\n",
      'Sum of Question Views' => "  0&nbsp;E <> 0\n"
    )
  end
  it do
    expect(decorated_project.agility_quarter_values(Time.parse('01.01.2016'))).to eq(
      'commits' => 11,
      'issues_actual_count' => 2,
      'issues_all_count' => 10,
      'issues_closed_percent' => 70,
      'issues_processed_in_avg' => 24,
      'issues_processed_in_median' => 1,
      'pr_actual_count' => 3,
      'pr_all_count' => 13,
      'pr_closed_percent' => 69,
      'pr_processed_in_avg' => 17,
      'pr_processed_in_median' => 16,
      'releases_count' => 1
    )
  end
  it do
    expect(decorated_project.community_quarter_values(Time.parse('01.01.2016'))).to eq(
      'answers_avg' => 0,
      'forks_count' => 51,
      'question_score_sum' => 0,
      'question_view_sum' => 0,
      'questioner_rep_median' => 0,
      'questioners_count' => 0,
      'questions_count' => 0,
      'questions_resolved_percent' => 0,
      'stargazers_count' => 2013,
      'total_downloads_count' => 15_435,
      'users_commenting_issues_count' => 7,
      'users_commenting_pr_count' => 19,
      'users_creating_issues_count' => 6,
      'users_creating_pr_count' => 5,
      'users_involved_count' => 2063,
      'users_involved_no_stars_count' => 50
    )
  end
end
