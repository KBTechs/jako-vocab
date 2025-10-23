package com.example.jako_vocab.api;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.jako_vocab.api.dto.AnswerRequest;
import com.example.jako_vocab.api.dto.AnswerResponse;
import com.example.jako_vocab.core.JudgeService;

/**
 * /answers エンドポイント
 * JSONで受け取った回答を判定し、結果を返す。
 */
@RestController
@RequestMapping("/answers")
public class AnswerController {

    private final JudgeService judge;

    public AnswerController(JudgeService judge) {
        this.judge = judge;
    }

    @PostMapping
    public ResponseEntity<AnswerResponse> answer(@Valid @RequestBody AnswerRequest req) {
        var out = judge.judge(req.direction(), req.text());
        return ResponseEntity.ok(new AnswerResponse(out.correct(), out.matched(), out.explanation()));
    }
}
