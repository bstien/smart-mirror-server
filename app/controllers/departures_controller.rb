class DeparturesController < ApplicationController
  def from
    stops = configuration[params[:area].to_sym]
    platforms = stops.map {|stop| stop[:platforms][params[:direction].to_sym]}.flatten.uniq

    departures = stops.map {|stop| Departure.from(stop[:id])}.flatten(1)
    departures.select! {|departure| platforms.include? departure.platform}
    departures.sort! {|a,b| Time.at(a.arrival true) <=> Time.at(b.arrival true) }

    render json: departures.take(5)
  end

  protected
  def configuration
    {
        birkelunden: [
            {
                id: 3010519,
                platforms: {
                    northbound: [1],
                    southbound: [2]
                }
            },
            {
                id: 3010520,
                platforms: {
                    northbound: [1],
                    southbound: [12]
                }
            }
        ]
    }
  end
end