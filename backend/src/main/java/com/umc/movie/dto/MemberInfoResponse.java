package com.umc.movie.dto;

import com.umc.movie.entity.Member;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class MemberInfoResponse {
    private String email;
    private String nickname;
    private LocalDateTime createdAt;

    // 엔티티를 그대로 내보내면 password까지 나가므로 DTO로 옮겨 담습니다
    public static MemberInfoResponse from(Member member) {
        return MemberInfoResponse.builder()
                .email(member.getEmail())
                .nickname(member.getNickname())
                .createdAt(member.getCreatedAt())
                .build();
    }
}