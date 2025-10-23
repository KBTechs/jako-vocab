package com.example.jako_vocab.api.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * 通知から送られてくる回答データ
 */
public record AnswerRequest(
        @NotBlank String quizId,
        @NotBlank String direction, // JA_KO | KO_JA | BOTH
        @NotBlank String text) {
}
