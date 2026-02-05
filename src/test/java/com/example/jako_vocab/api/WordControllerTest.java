package com.example.jako_vocab.api;

import com.example.jako_vocab.entity.Word;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class WordControllerTest {

	@LocalServerPort
	int port;

	final RestTemplate restTemplate = new RestTemplate();
	final ObjectMapper objectMapper = new ObjectMapper();

	String baseUrl() {
		return "http://localhost:" + port;
	}

	@Test
	void wordsApiReturnsSeededData() throws Exception {
		ResponseEntity<String> response = restTemplate.exchange(
				baseUrl() + "/api/words",
				HttpMethod.GET,
				null,
				String.class);

		assertThat(response.getStatusCode().is2xxSuccessful())
				.as("response: %s body: %s", response.getStatusCode(), response.getBody()).isTrue();
		assertThat(response.getBody()).isNotNull();

		List<Word> words = objectMapper.readValue(
				response.getBody(),
				new TypeReference<>() {});

		assertThat(words).hasSize(100);
		Word first = words.stream()
				.filter(w -> "안녕하세요".equals(w.getKorean()))
				.findFirst()
				.orElseThrow();
		assertThat(first.getJapanese()).isEqualTo("こんにちは");
		assertThat(first.getLevel()).isEqualTo("beginner");
	}

	@Test
	void wordsApiFilterByLevel() throws Exception {
		ResponseEntity<String> response = restTemplate.exchange(
				baseUrl() + "/api/words?level=beginner",
				HttpMethod.GET,
				null,
				String.class);

		assertThat(response.getStatusCode().is2xxSuccessful())
				.as("response: %s body: %s", response.getStatusCode(), response.getBody()).isTrue();
		assertThat(response.getBody()).isNotNull();

		List<Word> words = objectMapper.readValue(
				response.getBody(),
				new TypeReference<>() {});

		assertThat(words).hasSize(100);
		assertThat(words).allMatch(w -> "beginner".equals(w.getLevel()));
	}
}
