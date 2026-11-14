package com.umc.movie.service;

import com.umc.movie.dto.MemberInfoResponse;
import com.umc.movie.dto.MemberUpdateRequest;
import com.umc.movie.dto.SignupRequest;
import com.umc.movie.entity.Member;
import com.umc.movie.exception.ApiException;
import com.umc.movie.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MemberService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public MemberInfoResponse signup(SignupRequest request) {
        if (memberRepository.existsByEmail(request.getEmail())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "MEMBER_400", "이미 존재하는 이메일입니다.");
        }

        if (memberRepository.existsByNickname(request.getNickname())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "MEMBER_401", "이미 존재하는 닉네임입니다.");
        }

        Member member = Member.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .nickname(request.getNickname())
                .build();

        return MemberInfoResponse.from(memberRepository.save(member));
    }

    public MemberInfoResponse getMyInfo(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1",
                        "해당 회원을 찾을 수 없습니다."));
        return MemberInfoResponse.from(member);
    }

    @Transactional
    public MemberInfoResponse updateMyInfo(Long memberId, MemberUpdateRequest request) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "MEMBER404_1",
                        "해당 회원을 찾을 수 없습니다."));

        // 나를 제외한 다른 회원이 쓰는 닉네임이면 막습니다 (내 닉네임 그대로는 허용)
        if (memberRepository.existsByNicknameAndIdNot(request.getNickname(), memberId)) {
            throw new ApiException(HttpStatus.CONFLICT, "MEMBER409_1",
                    "이미 사용 중인 닉네임입니다.");
        }

        member.updateInfo(request.getNickname());
        memberRepository.save(member);

        return MemberInfoResponse.from(member);
    }
}