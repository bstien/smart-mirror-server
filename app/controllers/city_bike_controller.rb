class CityBikeController < ApplicationController
  def availability
    availability = CityBikeStation.availability configuration

    render json: availability
  end

  protected
  def configuration
    [
      {id: [39], name: 'Birkelunden'},
      {id: [52], name: 'Olaf Ryes'},
      {id: [143], name: 'Ringen Kino'},
      {id: [121,122], name: 'Dælenenggata'}
    ]
  end
end
