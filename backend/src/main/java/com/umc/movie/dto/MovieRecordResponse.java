package com.umc.movie.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class MovieRecordResponse {
    private RatingResponse rating;
    private FavoriteResponse favorite; // addToFavorites가 false면 null
}