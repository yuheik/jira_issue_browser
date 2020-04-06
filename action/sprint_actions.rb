require_relative './base_actions'
require_relative './analyzer'

class SprintActions < BaseActions
  def self.init
    if @issues.nil?
      get_sprint_issues
    end

    reset
    calc_kpi
  end

  def self.reset
    @browsing_issues = @issues.dup
    list
  end

  def self.get_sprint_issues
    @params   = input_query_param()
    query     = JiraApiCaller::build_query(@params)
    @issues   = JiraApiCaller.new.search(query)
    @analyzer = Analyzer.new(@issues)
  end

  def self.change_sprint
    get_sprint_issues
    reset
    calc_kpi
  end

  def self.input_query_param
    params = Hash.new
    params[:project] = Team::Project # mandatory

    puts "Sprint: "
    sprint, index = select_contents_from(["Active Sprint", *Team::Sprints])
    (sprint == "Active Sprint") ? params[:sprint] = 'active' : params[:sprint] = sprint

    return params
  end

  def self.list
    issues = @browsing_issues

    puts info_header
    puts border
    issues.each { |issue| puts info_of_(issue) }
    puts blankline
  end

  def self.browse
    loop do
      key, index = select_contents_from(["BACK", *BROWSE_ACTIONS.keys])
      break if key == "BACK"

      BROWSE_ACTIONS[key].call()
      calc_kpi
    end
  end

  def self.list_current
    self.list
  end

  def self.filter_type
    select_with_cancel(:title  => "Filter by IssueType",
                       :choice => Jira::Types) do |type|
      @browsing_issues.filter_by_type!(type)
      list
    end
  end

  def self.filter_status
    select_with_cancel(:title  => "Filter by Status",
                       :choice => Jira::SimpleStatus) do |type|
      @browsing_issues.filter_by_simple_status!(type)
      list
    end
  end

  def self.exclude_type
    select_with_cancel(:title  => "Exclude IssueType",
                       :choice => Jira::Types) do |type|
      @browsing_issues.exclude_by_type!(type)
      list
    end
  end

  def self.sort
    select_with_cancel(:title  => "Sort By",
                       :choice => ["Key", "Assignee", "Epic", "Status"]) do |type|
      case (type)
      when "Key"      ; @browsing_issues.sort_by!(:key)
      when "Assignee" ; @browsing_issues.sort_by!(:assignee)
      when "Epic"     ; @browsing_issues.sort_by!(:epic)
      when "Status"   ; @browsing_issues.sort_by!(:status)
      end
      list
    end
  end

  def self.calc_kpi
    complete_sprint = @params[:sprint]
    results = @analyzer.calc_kpi(complete_sprint, @browsing_issues)

    puts "#{complete_sprint} info"
    puts border
    puts "Sum StoryPoints                    : #{results[:sum_story_points]}"
    puts "Velocity                           : #{results[:velocity]}"
    puts "Acceptence Rate                    : #{results[:acceptence_rate]} %"
    puts "Sum Time Spent (All)               : #{results[:time_spent_all]} h "
    puts "Sum Time Spent (for Bug)           : #{results[:time_spent_for_bug]} h"
    puts "Sum Time Spent (Done SubTasks)     : #{results[:sum_time_spent_of_done_subtasks]} h"
    puts "Sum Time Estimated (Done SubTasks) : #{results[:sum_time_estimated_of_done_subtasks]} h"
    puts "Estimation Accuracy                : #{results[:estimation_accuracy]} %"
    puts "Bug Rate (for bug / for all)       : #{results[:bug_rate]} %"
    puts blankline
  end

  def self.check_story_points
    results = @analyzer.check_story_points()

    puts "check story points"
    puts "* : sp and sum remaining estimate not match. (can trust this only before starting sprint)"
    puts "x : sp is set to unnecessary issues (Story nor Spike)."
    puts "- : sp is not set even though sum remaining estimate is set."
    puts blankline
    puts check_story_points_header
    puts border
    results.each do |result|
      warn = ""
      case (result[:warn])
      when :unnecessary; warn = "x"
      when :incorrect;   warn = "*"
      when :missing;     warn = "-"
      end

      puts check_story_points_info_of_(warn,
                                       result[:issue],
                                       result[:sp_of_all],
                                       result[:sp_of_undones])
    end
    puts blankline
  end

  def self.no_subtasks_issues
    results = @analyzer.no_subtasks_issues

    puts "no subtasks issues"
    puts border
    results.each do |issue|
      puts no_subtasks_issues_info_of_(issue)
    end
    puts blankline
  end

  def self.should_be_closed_issues
    results = @analyzer.should_be_closed_issues

    puts "Issues which should be closed/accpeted"
    puts border
    results.each do |result|
      puts info_of_(result)
    end
    puts blankline
  end

  def self.list_with_epics
    epics = JiraApiCaller.new.search("key in (#{@issues.epic_keys.join(',')})")
    list_issues_group_by_epics(epics, @issues)
  end


  BROWSE_ACTIONS = {
    "List"          => SprintActions.method(:list_current),
    "Filter Type"   => SprintActions.method(:filter_type),
    "Filter Status" => SprintActions.method(:filter_status),
    "Exclude Type"  => SprintActions.method(:exclude_type),
    "Sort"          => SprintActions.method(:sort),
    "Reset"         => SprintActions.method(:reset)
  }
end
