class MoviesController < ApplicationController
before_action :authenticate_user! , only: [:new, :create, :edit, :update, :destroy]
before_action :find_movie_and_check_permission, only: [:edit, :update, :destroy]
  def index
    @movies = Movie.includes(:user).all
  end

  def new
    @movie = Movie.new
  end

  def create
   @movie = Movie.new(movie_params)
   @movie.user = current_user
   if @movie.save
     current_user.favorite!(@movie)
     redirect_to movies_path
   else
     render :new
 end
 end

 def show
   @movie = Movie.find(params[:id])
   @reviews = @movie.reviews.includes(:user).recent.paginate(:page => params[:page], :per_page => 5)
 end

 def edit
   @movie = Movie.find(params[:id])
   find_movie_and_check_permission
 end

 def update
    @movie = Movie.find(params[:id])
    find_movie_and_check_permission
    if @movie.update(movie_params)
    redirect_to movies_path, notice: "Update Success"
    else
      render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    find_movie_and_check_permission
    @movie.destroy
    flash[:alert] = "Movie deleted"
    redirect_to movies_path
  end

  def favorite
   @movie = Movie.find(params[:id])

    if !current_user.is_member_of?(@movie)
      current_user.favorite!(@movie)
      flash[:notice] = "收藏电影成功！"
    else
      flash[:warning] = "你已经收藏过该电影了！"
    end

    redirect_to movie_path(@movie)
  end

  def cancel
    @movie = Movie.find(params[:id])

    if current_user.is_member_of?(@movie)
      current_user.cancel!(@movie)
      flash[:alert] = "已取消收藏该电影！"
    else
      flash[:warning] = "你没有收藏该电影，怎么取消 XD"
    end

    redirect_to movie_path(@movie)
  end
 private

 def find_movie_and_check_permission
    @movie = Movie.find(params[:id])
    if current_user != @movie.user
      redirect_to root_path, alert: "You have no permission."
    end
  end

 def movie_params
   params.require(:movie).permit(:title, :description)
 end
end
