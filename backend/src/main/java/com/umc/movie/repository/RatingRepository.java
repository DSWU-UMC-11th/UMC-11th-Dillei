package com.umc.movie.repository;

import com.umc.movie.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {

    // 특정 회원이 작성한 평점 목록 조회 (최신순)
    // 👈 member_MemberId 를 member_Id 로 수정했습니다!
    List<Rating> findByMember_IdOrderByRatingIdDesc(Long memberId);

    // 특정 회원이 특정 영화에 이미 평점을 남겼는지 중복 확인
    // 👈 member_MemberId 를 member_Id 로 수정했습니다!
    boolean existsByMember_IdAndMovieId(Long memberId, Long movieId);
}