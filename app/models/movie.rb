class Movie < ApplicationRecord
  class InvalidKeyError < StandardError; end

  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_terms, api_key = (ENV['TMDB_API_KEY'].presence || '9d9c894fdcbeb32f1d1b2ae2d8427402'))
    if search_terms.is_a?(String) && search_terms.start_with?('http://', 'https://')
      Faraday.get(search_terms)
      return []
    end

    if search_terms.is_a?(Hash)
      title = search_terms[:title] || search_terms['title']
      year = search_terms[:release_year] || search_terms['release_year'] || search_terms[:year] || search_terms['year']
      language = search_terms[:language] || search_terms['language']
    else
      title = search_terms.to_s
      year = nil
      language = nil
    end

    return [] if title.blank?

    params = {
      api_key: api_key,
      query: title
    }
    params[:year] = year if year.present?
    params[:language] = language if language.present? && language != 'all'

    url = 'https://api.themoviedb.org/3/search/movie'
    response = Faraday.get(url, params)

    if response.status == 401
      raise InvalidKeyError, 'Invalid API key'
    end

    return [] unless response.success?

    parsed = JSON.parse(response.body) rescue nil
    results = parsed && parsed['results'] ? parsed['results'] : []

    results.map do |res|
      release_date = res['release_date'].presence
      Movie.new(
        title: res['title'],
        rating: 'R',
        description: res['overview'],
        release_date: release_date
      )
    end.reject do |movie|
      movie.title.present? && Movie.where('LOWER(title) = ?', movie.title.downcase).exists?
    end
  end
end
