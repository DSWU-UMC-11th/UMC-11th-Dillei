package com.umc.movie.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CreateFavoriteRequest {

    @NotNull(message = "영화 ID는 필수 입력 값입니다.")
    @Positive(message = "영화 ID는 양수여야 합니다.")
    private Long movieId;
}