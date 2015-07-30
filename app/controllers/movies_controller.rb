class MoviesController < ApplicationController

  skip_before_action :restrict_access, only: [:index, :show, :search]

  def index
    @movies = Movie.all.paginate(page: params[:page], per_page: 2)
  end

  def search
    query = params[:query]

    case params[:runtime].to_i
    when 0
      range = 0
    when 1
      range = 0...90
    when 2
      range = 90..120
    when 3
      range = 120...1000
      # TODO:
    end

    @movies = Movie.where("(lower(title) LIKE ? OR lower(director) LIKE ?) ", "%#{query[:title]}%", "%#{query[:director]}%").where(runtime_in_minutes: (range))
    if @movies.any?
      flash.now.alert = "found #{@movies.size} movies with #{params[:query]}"
      # why doesn't notice work here?
      render :index
    else
      redirect_to movies_path, notice: "No movies found under #{params[:query]}"
    end
  end

  def show
    @movie = Movie.find(params[:id])
  end

  def new
    @movie = Movie.new
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to movies_path, notice: "#{@movie.title} was submitted successfully!"
    else
      render :new
    end
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update_attributes(movie_params)
      redirect_to movie_path(@movie)
    else
      render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path
  end

  protected

  def movie_params
    params.require(:movie).permit(:title, :director, :runtime_in_minutes, :description, :poster_image_url, :release_date, :image, :remove_image)
  end

end
