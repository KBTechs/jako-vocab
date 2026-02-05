package com.example.jako_vocab.service;

import com.example.jako_vocab.entity.Word;
import com.example.jako_vocab.repository.WordRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class WordService {

	private final WordRepository wordRepository;

	/**
	 * DB に単語が1件もない場合、data/beginner_words.json を読み込んで投入する。
	 */
	@Transactional
	public void seedFromJsonIfEmpty() {
		if (wordRepository.count() > 0) {
			log.info("Words already exist, skipping seed.");
			return;
		}
		String path = "data/beginner_words.json";
		ObjectMapper objectMapper = new ObjectMapper();
		try (InputStream is = new ClassPathResource(path).getInputStream()) {
			List<Map<String, Object>> list = objectMapper.readValue(is, new TypeReference<>() {});
			List<Word> words = list.stream()
					.map(this::mapToWord)
					.collect(Collectors.toList());
			wordRepository.saveAll(words);
			log.info("Seeded {} words from {}", words.size(), path);
		} catch (IOException e) {
			log.warn("Could not load seed file {}: {}", path, e.getMessage());
		}
	}

	private Word mapToWord(Map<String, Object> m) {
		return Word.builder()
				.korean((String) m.get("korean"))
				.japanese((String) m.get("japanese"))
				.pronunciation((String) m.get("pronunciation"))
				.level((String) m.get("level"))
				.build();
	}

	public List<Word> findAll() {
		return wordRepository.findAll();
	}

	public List<Word> findByLevel(String level) {
		return wordRepository.findByLevel(level);
	}
}
