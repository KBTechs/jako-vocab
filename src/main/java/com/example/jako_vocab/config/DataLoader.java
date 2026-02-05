package com.example.jako_vocab.config;

import com.example.jako_vocab.service.WordService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataLoader implements ApplicationRunner {

	private final WordService wordService;

	@Override
	public void run(ApplicationArguments args) {
		wordService.seedFromJsonIfEmpty();
	}
}
