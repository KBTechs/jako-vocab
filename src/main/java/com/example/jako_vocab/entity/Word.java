package com.example.jako_vocab.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "words")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Word {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(nullable = false)
	private String korean;

	@Column(nullable = false)
	private String japanese;

	private String pronunciation;

	@Column(nullable = false)
	private String level;
}
