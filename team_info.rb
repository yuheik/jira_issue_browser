module Team
  SITE = "https://yuheik.atlassian.net"
  Project = "MYP"
  Sprints = (1..1).to_a.map { |i| "#{Project} Sprint #{i}" }.flatten.reverse!
  Members = [
  ]
end
