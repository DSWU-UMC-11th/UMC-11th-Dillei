package com.umc.movie.service;

import com.umc.movie.dto.CreateMovieRecordRequest;
import com.umc.movie.dto.FavoriteResponse;
import com.umc.movie.dto.MovieRecordResponse;
import com.umc.movie.dto.RatingResponse;
import com.umc.movie.entity.Favorite;
import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.exception.ApiException;
import com.umc.movie.repository.FavoriteRepository;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class MovieRecordService {

    private final MemberRepository memberRepository;
    private final RatingRepository ratingRepository;
    private final FavoriteRepository favoriteRepository;

    // 평점 저장과 즐겨찾기 저장을 하나의 트랜잭션으로 묶습니다.
    @Transactional
    public MovieRecordResponse create(Long memberId, CreateMovieRecordRequest request) {
        boolean addToFavorites = request.getAddToFavorites();

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1",
                        "해당 회원을 찾을 수 없습니다."));

        if (ratingRepository.existsByMember_IdAndMovieId(memberId, request.getMovieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "RATING409_1",
                    "이미 이 영화에 평점을 남기셨습니다.");
        }

        if (addToFavorites
                && favoriteRepository.existsByMember_IdAndMovieId(memberId, request.getMovieId())) {
            throw new ApiException(HttpStatus.CONFLICT, "FAVORITE409_1",
                    "이미 이 영화를 즐겨찾기하셨습니다.");
        }

        Rating savedRating = ratingRepository.save(Rating.builder()
                .member(member)
                .movieId(request.getMovieId())
                .score(request.getScore())
                .comment(request.getComment())
                .build());

        FavoriteResponse favoriteResponse = null;
        if (addToFavorites) {
            Favorite savedFavorite = favoriteRepository.save(Favorite.builder()
                    .member(member)
                    .movieId(request.getMovieId())
                    .build());
            favoriteResponse = FavoriteResponse.from(savedFavorite);
        }

        return MovieRecordResponse.builder()
                .rating(RatingResponse.from(savedRating))
                .favorite(favoriteResponse)
                .build();
    }
}