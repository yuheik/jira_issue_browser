# coding: utf-8

require 'rest-client'
require 'json'
require_relative './my_credential'

class JiraAccessor
  API_URL = "#{Credential::Site}/rest/api/2"

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
    begin
      response = RestClient::Request.new(:method     => :PUT,
                                         :url        => "#{API_URL}/issue/#{key}",
                                         :user       => Credential::UserName,
                                         :password   => Credential::Password,
                                         :proxy      => nil,
                                         :verify_ssl => false,
                                         :payload    => compose_payload(story_point),
                                         :headers    => { :content_type => "application/json;charset=UTF-8" }
                                        ).execute
    rescue RestClient::ExceptionWithResponse => e
      puts "Error: (#{e.message} with #{e.response})"
      puts "Failed: #{e.backtrace}"
      # puts e
    end

    # dump(response)
  end

  def self.dump(response)
    abort if response.class != RestClient::Response

    puts "Dump Response --"
    puts "code:       #{response.code}"
    puts "body:       #{response.body}"
    puts "headers:    #{JSON.pretty_generate(response.headers)}"
    puts "cookies:    #{JSON.pretty_generate(response.cookies)}"
    puts "cookie_jar: #{response.cookie_jar.inspect}"
    puts "request:    #{response.request.inspect}"
    puts "history:    #{response.history}"
  end
end
