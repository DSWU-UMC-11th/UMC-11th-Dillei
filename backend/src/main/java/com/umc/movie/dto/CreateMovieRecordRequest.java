package com.umc.movie.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class CreateMovieRecordRequest {

    @NotNull(message = "영화 ID는 필수 입력 값입니다.")
    @Positive(message = "영화 ID는 양수여야 합니다.")
    private Long movieId;

    @NotNull(message = "평점은 필수 입력 값입니다.")
    @Min(value = 1, message = "평점은 최소 1점 이상이어야 합니다.")
    @Max(value = 5, message = "평점은 최대 5점 이하여야 합니다.")
    private Integer score;

    @Size(max = 200, message = "한줄평은 200자 이하여야 합니다.")
    private String comment;

    @NotNull(message = "즐겨찾기 추가 여부는 필수 입력 값입니다.")
    private Boolean addToFavorites;
}