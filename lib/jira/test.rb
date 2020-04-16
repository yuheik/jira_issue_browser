#! /usr/bin/env ruby

require './jira_accessor'
require './jira_api_caller'

puts "----------------------------------------"
sp_to_set = rand(1..30)
puts "update #{sp_to_set}"
p JiraAccessor.update_issue("MYP-62", sp_to_set)

puts "----------------------------------------"
puts "get single"
p JiraApiCaller.get_issue("MYP-62")

puts "----------------------------------------"
puts "search"
JiraApiCaller.search(JiraApiCaller.build_query({ project: "MYP" })).sort_by!(:key).each do |issue|
  p issue
end
