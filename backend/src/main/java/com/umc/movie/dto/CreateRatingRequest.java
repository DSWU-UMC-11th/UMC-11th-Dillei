package com.umc.movie.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CreateRatingRequest {

        @NotNull(message = "영화 ID는 필수 입력 값입니다.")
        private Long movieId;

        @NotNull(message = "평점은 필수 입력 값입니다.")
        @Min(value = 1, message = "평점은 최소 1점 이상이어야 합니다.")
        @Max(value = 5, message = "평점은 최대 5점 이하여야 합니다.")
        private Integer score;

        private String comment;
}