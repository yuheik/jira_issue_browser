# coding: utf-8

require 'json'
require_relative './api_caller_restclient'
require_relative './my_credential'

class JiraAccessor < ApiCallerRestClient
  JIRA_URL = "#{Credential::Site}/rest/api/2"

  def self.compose_payload(story_point)
    param = Hash.new
    param[:fields] = Hash.new
    param[:fields][:customfield_10024] = story_point.to_f # TODO customfield depends on your Site.

    return JSON.pretty_generate(param).to_s
  end

  # NOTE:
  # To edit StoryPoint via script, StoryPoint field needs to be shown in JIRA screen.
  # Go to 'JIRA Software' from left top icon.
  # 'JIRA Settings' => 'Screens' => 'Default Issue Screen' Edit => 'Field Tab'.
  # Add 'Story Points' field there.
  def self.update_issue(key, story_point)
    call("#{JIRA_URL}/issue/#{key}",
         Credential::UserName,
         Credential::Password,
         :PUT,
         compose_payload(story_point))
  end
end
