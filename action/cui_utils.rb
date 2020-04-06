module CuiUtils
  $separator_mode = :blank
  $separator_type = {
    :none  => "",
    :blank => "  ",
    :csv   => ", ",
    :tab   => "\t"
  }

  def separator()
    return $separator_type[$separator_mode]
  end
  alias sp separator

  def temp_output(mode, &block)
    backup = $separator_mode
    $separator_mode = mode
    yield
    $separator_mode = backup
  end

  def clear_screen
    puts "\e[H\e[2J"
  end

  def border
    "-----------------------------------------------------------------------------" +
    "-----------------------------------------------------------------------------"
  end

  def blankline
    ""
  end

  def info_format
    "%-10s#{sp}" << # Key
    "%-10s#{sp}" << # Type
    "%-15s#{sp}" << # Status
    "%-10s#{sp}" << # Epic
    "%-10s#{sp}" << # Parent
    "%- 4s#{sp}" << # StoryPoint
    "%- 4s#{sp}" << # Original Estimate
    "%- 4s#{sp}" << # Remaining Estimate
    "%- 4s#{sp}" << # Time Spent
    "%-30s#{sp}" << # Assignee
    "%-25s#{sp}" << # Version
    "%s"            # Title
  end

  def info_header
    sprintf(info_format,
            "Key",
            "Type",
            "Status",
            "Epic",
            "Parent",
            "SP",
            "OE",
            "RE",
            "TS",
            "Assignee",
            "Version[0]",
            "Title")
  end

  def info_of_(issue)
    sprintf(info_format,
            issue.key,
            issue.type,
            issue.status,
            issue.epic,
            issue.parent_key,
            issue.story_points,
            sec_to_hour(issue.original_estimate),
            sec_to_hour(issue.remaining_estimate),
            sec_to_hour(issue.time_spent),
            issue.assignee,
            issue.versions[0] ? issue.versions[0].name : "", # TODO only first version is displayed
            issue.title)
  end

  def check_story_points_format
    "%- 5s#{sp}" << # WARN
    "%-10s#{sp}" << # Key
    "%-10s#{sp}" << # Type
    "%-15s#{sp}" << # Status
    "%- 3s#{sp}" << # Story Points
    "<=>#{sp}"   <<
    "%- 8s#{sp}" << # Sum of Estimate (converted into StoryPoints)
    "%- 8s#{sp}" << # Sum of Remaining Estimate (converted into StoryPoints)
    "%-30s#{sp}" << # Assignee
    "%s"            # Title
  end

  def check_story_points_header
    sprintf(check_story_points_format,
            "Warn",
            "Key",
            "Type",
            "Status",
            "SP",
            "Sum (E)",
            "Sum (R)",
            "Assignee",
            "Title")
  end

  def check_story_points_info_of_(warn, issue, sp_of_all, sp_of_undones)
    sprintf(check_story_points_format,
            warn,
            issue.key,
            issue.type,
            issue.status,
            issue.story_points,
            sp_of_all,
            sp_of_undones,
            issue.assignee,
            issue.title)
  end

  def no_subtasks_issues_format
    "%-10s#{sp}" << # Key
    "%-10s#{sp}" << # Type
    "%-30s#{sp}" << # Assignee
    "%s"            # Title
  end

  def no_subtasks_issues_info_of_(issue)
    sprintf(no_subtasks_issues_format,
            issue.key,
            issue.type,
            issue.assignee,
            issue.title)
  end

  def features_format
      "%-10s#{sp}" << # Key
      "%-10s#{sp}" << # Type
      "%-20s#{sp}" << # Status
      "%-25s#{sp}" << # Version [0]
      "%-25s#{sp}" << # Sprints (last)
      "%s"            # Title
  end

  def features_header
    sprintf(features_format,
            "Key",
            "Type",
            "Status",
            "Version [0]",
            "Sprints (last)",
            "Title")
  end

  def feature_info_of_(issue)
    sprintf(features_format,
            issue.key,
            issue.type,
            issue.status,
            issue.versions[0] ? issue.versions[0].name  : "",
            issue.sprint ? issue.sprint.name : "",
            issue.title)
  end

  def feature_info_of_related_(issue)
    sprintf("  " + features_format,
            issue.key,
            issue.type,
            issue.status,
            issue.versions[0] ? issue.versions[0].name  : "",
            issue.sprint ? issue.sprint.name : "",
            issue.title)
  end


  # future --------------------------------------------------------------------------------^

  def futures_format
    "%-15s#{sp}" << # Key
    "%-10s#{sp}" << # Type
    "%-20s#{sp}" << # Status
    "%- 8s#{sp}" << # StoryPoint
    "%-30s#{sp}" << # Assignee
    "%-25s#{sp}" << # Version
    "%s"        # Title
  end

  def futures_header
    sprintf(futures_format,
            "Key",
            "Type",
            "Status",
            "SP",
            "Assignee",
            "Version[0]",
            "Title")
  end

  def futures_epic_info_of_(issue)
    sprintf(futures_format,
            issue.key,
            issue.type,
            issue.status,
            issue.story_points,
            issue.assignee,
            issue.versions[0] ? issue.versions[0].name : "", # TODO only first version is displayed
            issue.title)
  end

  def futures_issue_info_of_(issue)
    sprintf("  " + futures_format,
            issue.key,
            issue.type,
            issue.status,
            issue.story_points,
            issue.assignee,
            issue.versions[0] ? issue.versions[0].name : "",
            issue.title)
  end
end
