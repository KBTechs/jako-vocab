package com.example.jako_vocab.repository;

import com.example.jako_vocab.entity.Word;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WordRepository extends JpaRepository<Word, Long> {

	List<Word> findByLevel(String level);
}
