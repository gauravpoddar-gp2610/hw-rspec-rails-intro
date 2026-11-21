require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with('hardware').
        and_return(@fake_results)
      get :search_tmdb, params: { search_terms: 'hardware' }
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { search_terms: 'hardware' }
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    describe 'with invalid parameters' do
      it 'displays an error message when title is blank' do
        get :search_tmdb, params: { title: '' }
        expect(flash[:danger] || flash[:alert] || flash[:warning]).to eq('Please fill in all required fields!')
        expect(response).to render_template('search_tmdb')
      end
    end

    describe 'when no movies match' do
      it 'displays a message when no movies are found' do
        allow(Movie).to receive(:find_in_tmdb).and_return([])
        get :search_tmdb, params: { title: 'UnknownMovieTitleXYZ' }
        expect(flash[:warning] || flash[:danger] || flash[:alert]).to eq('No movies found with given parameters!')
        expect(response).to render_template('search_tmdb')
      end
    end
  end

  describe 'adding a movie from TMDb' do
    it 'creates a new movie with the specified parameters' do
      expect {
        post :add_movie, params: { title: 'Limitless', rating: 'R', release_date: '2011-03-08', description: 'A thriller' }
      }.to change(Movie, :count).by(1)
      movie = Movie.find_by(title: 'Limitless')
      expect(movie).not_to be_nil
      expect(movie.rating).to eq('R')
    end

    it 'redirects to /search with a success flash message' do
      post :add_movie, params: { title: 'Limitless', rating: 'R', release_date: '2011-03-08', description: 'A thriller' }
      expect(flash[:success] || flash[:notice]).to eq('Limitless was successfully added to RottenPotatoes.')
      expect(response).to redirect_to(search_tmdb_path)
    end
  end
end
