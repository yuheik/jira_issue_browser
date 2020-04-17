#! /usr/bin/env ruby
# coding: utf-8

require_relative './lib/my_ruby_utils/my_ruby_utils'
require_relative './action/sprint_actions'
require_relative './action/feature_actions'
require_relative './action/roadmap_actions'

include MyRubyUtils


# for debug
# puts JiraApiCaller.get_issue("MYP-11") # sub-task

# -- Sprint Actions ------------------------------------------------------------

SPRINT_ACTIONS = {
  "Browse"                  => SprintActions.method(:browse),
  "KPI"                     => SprintActions.method(:calc_kpi),
  "Story Points"            => SprintActions.method(:check_story_points),
  "No subtask issues"       => SprintActions.method(:no_subtasks_issues),
  "Should be closed issues" => SprintActions.method(:should_be_closed_issues),
  "List with Epics"         => SprintActions.method(:list_with_epics),
  "Change Sprint"           => SprintActions.method(:change_sprint),
}

def sprint_action
  SprintActions.init

  loop do
    key, index = select_contents_from(["BACK", *SPRINT_ACTIONS.keys])

    if SPRINT_ACTIONS[key]
      SPRINT_ACTIONS[key].call()
    else
      break;
    end
  end
end


# -- Feature Actions -----------------------------------------------------------

FEATURE_ACTIONS = {
  "Filter Epics by Status"       => FeatureActions.method(:filter_epics),
  "Filter Epic Issues by Status" => FeatureActions.method(:filter_stories),
  "Sort Epics"                   => FeatureActions.method(:sort),
  "Toggle Stories"               => FeatureActions.method(:toggle_stories),
  "Reset"                        => FeatureActions.method(:reset),
  "Export to csv"                => FeatureActions.method(:export_to_csv)
}

def feature_action
  FeatureActions.init

  loop do
    key, index = select_contents_from(["BACK", *FEATURE_ACTIONS.keys])

    if FEATURE_ACTIONS[key]
      FEATURE_ACTIONS[key].call()
    else
      break;
    end
  end
end


# -- Roadmap Actions -----------------------------------------------------------

ROADMAP_ACTIONS = {
  "Toggle Stories" => RoadmapActions.method(:toggle_stories)
}

def roadmap_action
  RoadmapActions.init

  loop do
    key, index = select_contents_from(["BACK", *ROADMAP_ACTIONS.keys])

    if ROADMAP_ACTIONS[key]
      ROADMAP_ACTIONS[key].call()
    else
      break;
    end
  end
end


# - main -----------------------------------------------------------------------

MAIN_ACTIONS = {
  "Sprint"   => method(:sprint_action),
  "Features" => method(:feature_action),
  "Roadmap"  => method(:roadmap_action),
}

loop do
  key, index = select_contents_from(["EXIT", *MAIN_ACTIONS.keys])

  if MAIN_ACTIONS[key]
    MAIN_ACTIONS[key].call()
  else
    break;
  end
end
