package com.example.jako_vocab.api.dto;

/**
 * 判定結果をクライアントへ返すレスポンスDTO
 */
public record AnswerResponse(
        boolean correct,
        String matched,
        String explanation) {
}
