module ReviewsHelper

  def star_rating rating
    return rating if rating == 'N/A'
    '★' * rating
  end

end
