package com.umc.movie.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class FavoriteStatusResponse {
    // boolean이 아니라 Boolean: JSON 키가 "isFavorite"으로 나갑니다 (ApiResponse.isSuccess와 같은 이유)
    private Boolean isFavorite;
}