module Team
  SITE = "https://yuheik.atlassian.net"
  Project = "MYP"
  Sprints = (1..1).to_a.map { |i| "#{Project} Sprint #{i}" }.flatten.reverse!
  Members = [
  ]

  module TG
    Project = "OMTG"
    Lead    = "Fujimoto, Atsuhiko (SIE)"
  end
end
