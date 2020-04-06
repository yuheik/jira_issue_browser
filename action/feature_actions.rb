require_relative './base_actions'
require_relative '../my_utils'

class FeatureActions < BaseActions
  def self.init
    if @epics.nil?
      get_epics_and_its_issues
    end

    @show = { :stories => true }
    reset
  end

  def self.reset
    @browsing_epics = @epics.dup
    @browsing_epic_issues = @epic_issues.dup
    list
  end

  def self.get_epics_and_its_issues
    # TODO epic / sub-epic structure depends on team or organization
    @epics = JiraApiCaller.new.search(JiraApiCaller.build_query({ :project  => Team::TG::Project,
                                                                  :assignee => Team::TG::Lead }))

    sub_epics = JiraApiCaller.new
                  .search(JiraApiCaller.build_query({ :project     => Team::Project,
                                                      :filter_type => "Epic" }))
                  .select { |epic| epic.key =~ /SMGR-[0-9][0-9][0-9][0-9][0-9]/ } # TODO If key is under 5 digits, it's too old to refer.
    @epics.concat(sub_epics)

    @epic_issues = JiraApiCaller.new.search(JiraApiCaller.build_query({ :project  => Team::Project,
                                                                        :epiclink => @epics.map { |epic| epic.key } }))
  end

  def self.filter_epics
    select_with_cancel(:title  => "Filter by Status",
                       :choice => Jira::SimpleStatus) do |type|
      @browsing_epics.filter_by_simple_status!(type)
      list
    end
  end

  def self.filter_stories
    select_with_cancel(:title  => "Filter by Status",
                       :choice => Jira::SimpleStatus) do |type|
      @browsing_epic_issues.filter_by_simple_status!(type)
      list
    end
  end

  def self.sort
    type = select_with_cancel(:title  => "Sort Epics By",
                              :choice => ["Key", "Version"]) do |type|
      case (type)
      when "Key"     ; @browsing_epics.sort_by!(:key)
      when "Version" ; @browsing_epics.sort_by!(:version) # TODO only version[0] is used
      end
      list
    end
  end

  def self.toggle_stories
    @show[:stories] = !@show[:stories]
    list
  end

  def self.list
    epics = @browsing_epics
    epic_issues = @browsing_epic_issues

    puts features_header
    puts border
    epics.each do |epic|
      puts feature_info_of_(epic)

      if @show[:stories]
        eissues = epic_issues.select { |eissue| eissue.epic == epic.key }
        eissues.sort_by!(:sprint)
        eissues.each do |eissue|
          puts feature_info_of_related_(eissue)
        end
      end
      puts blankline if @show[:stories]
    end
    puts blankline
  end

  def self.export_to_csv
    require 'date'
    dump_to_file("features_#{Time.now.strftime("%Y-%m-%d_%H-%M")}.csv") do
      temp_output(:csv) do
        list
      end
    end
  end
end
