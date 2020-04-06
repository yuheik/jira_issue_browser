require_relative './base_actions'

class RoadmapActions < BaseActions
  def self.init
    if @issues.nil?
      @issues       = get_issues_linked_with_epic
      @sprint_names = @issues.map { |issue| issue.sprint ? issue.sprint.name : nil }.uniq.compact.sort
      @epics        = JiraApiCaller.new.search("key in (#{@issues.epic_keys.join(', ')})")
    end

    @show = { :stories => true }
    list
  end

  def self.get_issues_linked_with_epic
    return JiraApiCaller.new.search("project = #{Team::Project} AND status not in (Accepted, Completed, Done, Closed) AND \"Epic Link\" != EMPTY")
  end

  def self.list
    @sprint_names.each do |sprint_name|
      puts border
      puts sprint_name
      puts blankline
      sprint_issues = @issues.select_issues_which_(:sprint_name, sprint_name)
      sprint_epics  = @epics.select_issues_which_(:key, sprint_issues.epic_keys)
      list_issues_group_by_epics(sprint_epics, sprint_issues, @show[:stories])
      puts blankline unless @show[:stories]
    end

    puts border
    puts "Backlog"
    puts blankline
    sprint_issues = @issues.select_issues_which_(:sprint_name, nil)
    sprint_epics  = @epics.select_issues_which_(:key, sprint_issues.epic_keys)
    list_issues_group_by_epics(sprint_epics, sprint_issues, @show[:stories])
    puts blankline unless @show[:stories]
  end

  def self.toggle_stories
    @show[:stories] = !@show[:stories]
    list
  end
end
