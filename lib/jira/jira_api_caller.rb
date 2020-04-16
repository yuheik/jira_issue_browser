#! /usr/bin/ruby

require 'json'
require 'benchmark'
require_relative './api_caller'
require_relative './my_credential.rb'
require_relative './jira'

SeachType = :parallel           # or :sequence

class JiraApiCaller < ApiCaller
  JIRA_URL = "#{Credential::Site}/rest/api/2"
  INITIAL_SEARCH_SIZE = 1
  MAX_SEARCH_RESULTS  = 5
  # MAX_SEARCH_RESULTS  = 100   # for sequence

  def call(url, silent = false)
    body = super("#{JIRA_URL}/#{url}", Credential::UserName, Credential::Password, silent)
    # puts body # dump this to create raw json
    # abort

    json = JSON.parse(body)
    return json
  end

  def get_issue(issue_id)
    json = call("issue/#{issue_id}")

    Jira::Issue.new(json)
  end

  def search_with_range(query, index, max_num_of_results, silent = false)
    url  = "search?jql=#{URI.escape(query)}"
    url += "&startAt=#{index}"
    url += "&maxResults=#{max_num_of_results}" # setting 'maxResults' will fasten search
    json = call(url, silent)

    return json
  end

  def to_issues(json)
    return json["issues"].map { |issue_json| Jira::Issue.new(issue_json) }
  end

  # main purpose is to know whole size
  def initial_search_call(query, size)
    json = search_with_range(query, 0, size, false)
    issues = to_issues(json)
    total = json["total"]

    return issues, total
  end

  def search_parallel_call(query, start_index, total)
    index   = start_index
    threads = Array.new
    results = Array.new
    i = 0

    loop do
      results[i] = Array.new

      threads << Thread.new(query, index, results[i]) do | query, index, results |
        json = search_with_range(query, index, MAX_SEARCH_RESULTS, true)
        results << to_issues(json)
      end

      break if index + MAX_SEARCH_RESULTS >= total
      index += MAX_SEARCH_RESULTS
      i = i + 1
    end

    threads.each { |thread| thread.join }

    return results.flatten!
  end

  def search(query)
    return search_in_parallel(query)
    # return search_in_sequence(query) # Leave this for debug.
  end

  def search_in_parallel(query)
    puts "search with query: #{query}"
    puts ""

    issues = Array.new
    total  = 0

    benchmark_result = Benchmark.realtime do
      benchmark_first_request = Benchmark.realtime do
        issues, total = initial_search_call(query, INITIAL_SEARCH_SIZE)
      end

      puts "#{issues.size} / #{total} completed. (init request : #{benchmark_first_request.floor}s)"
      puts ""

      issues += search_parallel_call(query, INITIAL_SEARCH_SIZE, total) if (issues.size < total)
    end

    puts "#{issues.size} / #{total} completed. (total sequence : #{benchmark_result.floor}s)"
    puts ""

    return issues
  end

  def search_in_sequence(query)
    puts "search with query: #{query}"
    puts ""

    issues = Array.new

    benchmark_result = Benchmark.realtime do
      index = 0
      loop do
        json = search_with_range(query, index, MAX_SEARCH_RESULTS)
        json["issues"].each do |json_issue|
          issues.push(Jira::Issue.new(json_issue))
        end

        puts "#{issues.size} / #{json["total"]} completed."
        puts ""

        break if index + MAX_SEARCH_RESULTS >= json["total"]
        index += MAX_SEARCH_RESULTS
      end
    end

    puts "issue num : #{issues.size} (#{benchmark_result.floor}s)"
    puts ""

    return issues
  end

  #
  # @param params[:project]      Project name. Mandatory.
  # @param params[:sprint]       'Sprint name' or 'active' or nil
  # @param params[:filter_type]  issue type which will be filtered or nil
  # @param params[:exclude_type] issue type which will be excluded or nil
  # @param params[:epiclink]     issues which epic link would be
  #
  def self.build_query(params)
    abort "params is not Hash" if params.class != Hash
    abort "project is missing" if params[:project].nil?

    jql = "project = #{params[:project]} "

    if params[:sprint]
      if params[:sprint] == 'active'
        jql += "AND sprint in openSprints() "
      else
        jql += "AND sprint = \"#{params[:sprint]}\" "
      end
    end

    jql += "AND type = \"#{params[:filter_type]}\" "                 if params[:filter_type]
    jql += "AND type != \"#{params[:exclude_type]}\" "               if params[:exclude_type]
    jql += "AND assignee = \"#{params[:assignee]}\" "                if params[:assignee]
    jql += "AND \"Epic Link\" in (#{params[:epiclink].join(', ')}) " if params[:epiclink]
    jql += "ORDER BY Rank "

    return jql
  end
end
