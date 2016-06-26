require 'open-uri'
require 'json'

class CityBikeStation
  def initialize(name, availability)
    @name = name
    @availability = availability
  end

  def available_locks
    @availability[:locks]
  end

  def available_bikes
    @availability[:bikes]
  end

  def as_json(options = {})
    {
      name: @name,
      availability: {
        bikes: available_bikes,
        locks: available_locks
      }
    }
  end

  def self.availability(wanted_stations)
    url = 'https://oslobysykkel.no/api/v1/stations/availability'
    data = JSON.load(open url)['stations']
    stations = []

    wanted_stations.each do |wanted_station|
      availability = {locks: 0, bikes: 0}
      wanted_station[:id].each do |id|
        avail_info = data.find { |x| x['id'] == id }['availability']
        availability[:locks] += avail_info['locks']
        availability[:bikes] += avail_info['bikes']
      end
      stations << CityBikeStation.new(wanted_station[:name], availability)
    end

    stations
  end
end