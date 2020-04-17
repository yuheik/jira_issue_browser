require_relative '../team_info'
require_relative '../lib/jira/jira_api_caller'
require_relative '../lib/jira/search_query_builder'
require_relative './cui_utils'

include CuiUtils
include JiraApi

class BaseActions
  CANCEL = "CANCEL"

  def self.select_with_cancel(title:, choice:, &block)
    puts "#{title}:"
    item, index = select_contents_from([CANCEL, *choice])
    return if item == CANCEL
    yield(item)
  end

  def self.list_issues_group_by_epics(epics, issues, show_issues = true)
    abort unless epics.is_a? Array
    abort unless issues.is_a? Array

    epics.sort_by!(:key).each do |epic|
      puts futures_epic_info_of_(epic)

      if show_issues
        epic_issues = issues.select_issues_which_(:epic, epic)
        epic_issues.sort_by!(:key).each do |issue|
          puts futures_issue_info_of_(issue)
        end
        puts blankline
      end
    end
    puts blankline
  end

end
