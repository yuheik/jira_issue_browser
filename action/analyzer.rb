class Analyzer
  @issues

  def initialize(issues)
    abort "issues is not Array" unless issues.class == Array

    @issues = issues
  end

  def sec_to_sp(sec)
    return (sec_to_hour(sec) / 6.0).round(1)
  end

  def calc_kpi(complete_sprint, issues)
    story_points        = 0
    done_story_points   = 0
    time_estimated      = 0
    time_spent          = 0
    time_spent_all      = 0
    acceptence_rate     = 0
    estimation_accuracy = 0
    time_spent_for_bug  = 0

    issues.each do |issue|
      if issue.story_points
        story_points += issue.story_points # commited story points
        done_story_points += issue.story_points if issue.done_at_(complete_sprint) # done story points
      end

      # Exclude issues which are not estimated in order to calculate estimation accuracy.
      if issue.subtask?
        if issue.done?
          time_estimated += issue.original_estimate if issue.original_estimate
          time_spent     += issue.time_spent        if issue.time_spent
        end
        time_spent_all += issue.time_spent if issue.time_spent
      end

      if issue.bug?
        issue.select_subtasks_from_(@issues).each do |subtask|
          time_spent_for_bug += subtask.time_spent if subtask.time_spent
        end
      end
    end

    return {
      :sum_story_points                    => story_points,
      :velocity                            => done_story_points, # sum of done story points
      :acceptence_rate                     => percentage(done_story_points, story_points),
      :sum_time_estimated_of_done_subtasks => sec_to_hour(time_estimated),
      :sum_time_spent_of_done_subtasks     => sec_to_hour(time_spent),
      :estimation_accuracy                 => percentage(time_spent, time_estimated),
      :time_spent_for_bug                  => sec_to_hour(time_spent_for_bug),
      :time_spent_all                      => sec_to_hour(time_spent_all),
      :bug_rate                            => percentage(time_spent_for_bug, time_spent_all)
    }
  end


  #
  # @return array of hash
  # { :issue         => issue,
  #   :sp_of_all     => story point calculated from the sum of subtasks' original estimate
  #   :sp_of_undones => story point calculated from the sum of 'undone' subtasks' original estimate
  #   :warn          => symbol.
  #                     :none        => No problem.
  #                     :incorrect   => Story point calculated from subtasks and the one set to Issue not match.
  #                     :unnecessary => Issues except Story or Spike don't have to set story point.
  #                     :missing     => Story point is not set.
  # }
  #
  def check_story_points
    result = Array.new

    @issues.each do |issue|
      next if issue.subtask?

      sum_original_estimate        = 0
      sum_undone_original_estimate = 0

      issue.select_subtasks_from_(@issues).each do |subtask|
        if subtask.original_estimate
          sum_original_estimate        += subtask.original_estimate
          sum_undone_original_estimate += subtask.original_estimate unless subtask.done?
        end
      end

      sp_of_all_subtasks    = sec_to_sp(sum_original_estimate)
      sp_of_undone_subtasks = sec_to_sp(sum_undone_original_estimate)

      warn = :none
      if issue.bug? || issue.question?
        warn = :unnecessary if issue.story_points

      else
        if issue.story_points
          if ((sp_of_undone_subtasks * 2).ceil != issue.story_points * 2)
            warn = :incorrect
          end
        elsif sp_of_undone_subtasks != 0.0
          warn = :missing
        end
      end

      result << { :issue         => issue,
                  :sp_of_all     => sp_of_all_subtasks,
                  :sp_of_undones => sp_of_undone_subtasks,
                  :warn          => warn }
    end

    return result
  end

  #
  # pickup Issues which sub-tasks are not set.
  #
  def no_subtasks_issues
    results = Array.new

    @issues.each do |issue|
      next if issue.subtask?
      results << issue unless issue.has_subtasks?
    end

    return results
  end

  #
  # Find issues which sub-tasks are all done.
  #
  def should_be_closed_issues
    results = Array.new

    @issues.each do |issue|
      next if issue.subtask?
      next unless issue.has_subtasks?
      next if issue.done?

      all_done = true

      issue.select_subtasks_from_(@issues).each do |subtask|
        all_done = false unless subtask.done?
      end

      results << issue if all_done
    end

    return results
  end
end
