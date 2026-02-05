package com.example.jako_vocab.api;

import com.example.jako_vocab.entity.Word;
import com.example.jako_vocab.service.WordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/words")
@RequiredArgsConstructor
@Tag(name = "words", description = "単語 API")
public class WordController {

	private final WordService wordService;

	@GetMapping
	@Operation(summary = "単語一覧", description = "レベル指定がなければ全件、level があればそのレベルでフィルタ")
	public ResponseEntity<List<Word>> list(@RequestParam(required = false) String level) {
		List<Word> words = level == null || level.isBlank()
				? wordService.findAll()
				: wordService.findByLevel(level.trim());
		return ResponseEntity.ok(words);
	}
}
