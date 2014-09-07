class Card
  attr_accessor :section, :start_date, :start_time, :home_away, :rival

  def initialize(section, start_date, start_time, home_away, rival)
    @section, @start_date, @start_time, @home_away, @rival = section, start_date, start_time, home_away, rival
  end

  def to_s
    to_h.to_s
  end

  def to_h
    {
      section: section,
      kickoff_at: kickoff_at,
      home_away: home_away,
      rival: rival
    }
  end

  def kickoff_at
    if start_time
      DateTime.strptime("#{start_date} #{start_time}JST", '%Y/%m/%d %H:%M %Z')
    else
      Date.strptime(start_date, '%Y/%m/%d')
    end
  end

  def defined?
    !!start_time
  end
end
