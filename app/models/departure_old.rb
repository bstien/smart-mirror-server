require 'open-uri'
require 'json'

class DepartureOld

  def initialize(data)
    @raw_data = data['MonitoredVehicleJourney']
  end

  def line
    {number: @raw_data['LineRef'].to_i, name: @raw_data['MonitoredCall']['DestinationDisplay']}
  end

  def arrival(raw=false)
    return @raw_data['MonitoredCall']['ExpectedArrivalTime'] if raw
    {expected: humanize_time(@raw_data['MonitoredCall']['ExpectedArrivalTime']), aimed: humanize_time(@raw_data['MonitoredCall']['AimedArrivalTime'], false)}
  end

  def departure(raw=false)
    return @raw_data['MonitoredCall']['ExpectedDepartureTime'] if raw
    {expected: humanize_time(@raw_data['MonitoredCall']['ExpectedDepartureTime']), aimed: humanize_time(@raw_data['MonitoredCall']['AimedDepartureTime'], false)}
  end

  def platform
    @raw_data['MonitoredCall']['DeparturePlatformName'].to_i
  end

  def origin
    {id: @raw_data['OriginRef'].to_i, name: @raw_data['OriginName']}
  end

  def destination
    {id: @raw_data['DestinationRef'].to_i, name: @raw_data['DestinationName']}
  end

  def as_json(options={})
    {
      line: line,
      arrival: arrival,
      departure: departure,
      platform: platform,
      origin: origin,
      destination: destination
    }
  end

  def self.from(location_id)
    url = 'http://reisapi.ruter.no/StopVisit/GetDepartures/'+location_id.to_s
    departures = []
    (JSON.load open(url)).each do |departure|
      departures << self.new(departure)
    end

    departures
  end

  protected
  def humanize_time(timestamp, relative = true)
    time = Time.parse timestamp
    diff = time - Time.now
    return time.to_formatted_s :time if diff > 900 || diff < 0 || !relative
    return 'nå' if diff < 60
    ((diff / 1.minute).round).to_s + ' min'
  end
end