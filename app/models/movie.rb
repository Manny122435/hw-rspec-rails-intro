class Movie < ActiveRecord::Base

  def self.find_in_tmdb(params, api_key = "7ffd8228c7a7f8b2dffa0b64923ccc7f")
    base_url = "https://api.themoviedb.org/3/search/movie"
    
    query_params = {
      api_key: api_key,
      query: params[:title],
      language: params[:language]
    }
    
    if params[:release_year].present?
      query_params[:year] = params[:release_year]
    end

    begin
      response = Faraday.get(base_url, query_params)
    rescue Faraday::Error => e
      # Handle connection errors
      Rails.logger.error "Faraday error: #{e.message}"
      return []
    end

    # Parse the JSON response
    if response.success?
      results = JSON.parse(response.body)["results"]
      
      return [] if results.blank?

      # Map the results to NEW, UNSAVED Movie objects
      movies = results.map do |movie_data|
        Movie.new(
          title: movie_data["title"],
          release_date: movie_data["release_date"],
          rating: 'R',
          description: movie_data["overview"]
        )
      end
      return movies
    else
      Rails.logger.error "TMDb API error: #{response.status} #{response.body}"
      return []
    end
  end

end