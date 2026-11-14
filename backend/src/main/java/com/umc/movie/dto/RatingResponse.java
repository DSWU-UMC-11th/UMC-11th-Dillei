package com.umc.movie.dto;

import com.umc.movie.entity.Rating;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class RatingResponse {
    private Long ratingId;
    private Long movieId;
    private Integer score;
    private String comment;

    public static RatingResponse from(Rating rating) {
        return RatingResponse.builder()
                .ratingId(rating.getRatingId())
                .movieId(rating.getMovieId())
                .score(rating.getScore())
                .comment(rating.getComment())
                .build();
    }
}