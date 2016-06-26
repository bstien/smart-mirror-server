require 'open-uri'
require 'json'

class Departure

  def initialize(data)
    @raw_data = data
  end

  def line
    {number: @raw_data['LineRef'].to_i, name: @raw_data['DestinationDisplay']}
  end

  def arrival(raw=false)
    return get_timestamp 'ExpectedArrivalTime' if raw
    {expected: humanize_time(get_timestamp 'ExpectedArrivalTime'), aimed: humanize_time(get_timestamp('AimedArrivalTime'), false)}
  end

  def departure(raw=false)
    return get_timestamp 'ExpectedDepartureTime' if raw
    {expected: humanize_time(get_timestamp 'ExpectedDepartureTime'), aimed: humanize_time(get_timestamp('AimedDepartureTime'), false)}
  end

  def platform
    @raw_data['DeparturePlatformName'].to_i
  end

  def origin
    {id: @raw_data['OriginRef'].to_i, name: @raw_data['OriginName']}
  end

  def destination
    {id: @raw_data['DestinationRef'].to_i, name: @raw_data['DestinationName']}
  end

  def get_timestamp(value)
    @raw_data[value].slice(6, 10).to_i
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
    url = 'http://reis.ruter.no/ReisRest/RealTime/GetRealTimeData/'+location_id.to_s
    departures = []
    (JSON.load open(url)).each do |departure|
      departures << self.new(departure)
    end

    departures
  end

  protected
  def humanize_time(timestamp, relative = true)
    time = Time.at timestamp
    diff = time - Time.now
    return time.to_formatted_s :time if diff > 900 || diff < 0 || !relative
    return 'nå' if diff < 60
    ((diff / 1.minute).round).to_s + ' min'
  end
end