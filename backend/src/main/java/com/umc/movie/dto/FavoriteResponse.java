package com.umc.movie.dto;

import com.umc.movie.entity.Favorite;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class FavoriteResponse {
    private Long favoriteId;
    private Long movieId;
    private LocalDateTime createdAt;

    public static FavoriteResponse from(Favorite favorite) {
        return FavoriteResponse.builder()
                .favoriteId(favorite.getFavoriteId())
                .movieId(favorite.getMovieId())
                .createdAt(favorite.getCreatedAt())
                .build();
    }
}