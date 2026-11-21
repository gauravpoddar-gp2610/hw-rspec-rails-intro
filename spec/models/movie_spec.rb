require 'rails_helper'
require 'spec_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).at_least(:once).and_call_original
      Movie.find_in_tmdb({title: 'hacker', language: 'en'})
    end

    it 'calls TMDb with valid API key' do
      movies = Movie.find_in_tmdb({title: 'hacker', language: 'en'})
      expect(movies).not_to be_nil
    end

    it 'returns a list of unsaved Movie objects with rating R' do
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000'})
      expect(movies).to be_an(Array)
      expect(movies.length).to eq(2)
      expect(movies.first).to be_a(Movie)
      expect(movies.first.new_record?).to be true
      expect(movies.first.rating).to eq('R')
      expect(movies.first.title).to eq('Sydney 2000 Olympics Opening Ceremony')
    end

    it 'raises an InvalidKeyError when API key is invalid' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 401, body: '{"status_code":7,"status_message":"Invalid API key"}', headers: {})
      expect { Movie.find_in_tmdb({title: 'hacker'}, 'invalid_key') }.to raise_error(Movie::InvalidKeyError)
    end

    it 'returns an empty list when no movies are found' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: '{"page":1,"results":[],"total_pages":0,"total_results":0}', headers: {})
      movies = Movie.find_in_tmdb({title: 'NonExistentMovieXYZ'})
      expect(movies).to eq([])
    end

    it 'filters out movies that already exist in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R', release_date: '2000-09-15')
      movies = Movie.find_in_tmdb({title: 'Olympics', release_year: '2000'})
      expect(movies.length).to eq(1)
      expect(movies.first.title).to eq('Sydney 2000 Olympics Closing Ceremony')
    end
  end
end
