package com.umc.movie.repository;

import com.umc.movie.entity.Favorite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FavoriteRepository extends JpaRepository<Favorite, Long> {

    List<Favorite> findByMember_IdOrderByFavoriteIdDesc(Long memberId);

    Optional<Favorite> findByMember_IdAndMovieId(Long memberId, Long movieId);

    boolean existsByMember_IdAndMovieId(Long memberId, Long movieId);
}