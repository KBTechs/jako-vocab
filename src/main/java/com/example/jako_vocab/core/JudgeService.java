package com.example.jako_vocab.core;

import org.springframework.stereotype.Service;

import java.text.Normalizer;
import java.util.*;

/**
 * 回答文字列を正規化して、許容解答に部分一致したら正解とするサービス。
 * 今は擬似データで動作し、明日DBへ置き換え予定。
 */
@Service
public class JudgeService {

    // 韓国語→日本語の許容解答
    private static final Map<String, List<String>> KO_VARIANTS = Map.of(
            "감사합니다", List.of("감사합니다", "감사합니디", "감사함니다"),
            "안녕하세요", List.of("안녕하세요", "안뇽하세요"));

    // 日本語→韓国語の許容解答
    private static final Map<String, List<String>> JA_VARIANTS = Map.of(
            "ありがとう", List.of("ありがとう", "有難う"),
            "こんにちは", List.of("こんにちは", "こんにちわ"));

    /** 判定結果 */
    public record Outcome(boolean correct, String matched, String explanation) {
    }

    /**
     * direction に応じて判定を行う
     */
    public Outcome judge(String direction, String userText) {
        String norm = normalize(userText);

        if ("KO_JA".equalsIgnoreCase(direction) || "BOTH".equalsIgnoreCase(direction)) {
            for (var e : JA_VARIANTS.entrySet()) {
                for (var v : e.getValue()) {
                    if (match(norm, normalize(v))) {
                        return new Outcome(true, e.getKey(), "丁寧：ありがとうございます。韓国語は “감사합니다”。");
                    }
                }
            }
        }

        if ("JA_KO".equalsIgnoreCase(direction) || "BOTH".equalsIgnoreCase(direction)) {
            for (var e : KO_VARIANTS.entrySet()) {
                for (var v : e.getValue()) {
                    if (match(norm, normalize(v))) {
                        return new Outcome(true, e.getKey(), "カジュアル：고마워。丁寧：감사합니다。");
                    }
                }
            }
        }

        return new Outcome(false, null, "該当なし。代表例：ありがとう / 감사합니다");
    }

    // ---- 以下ユーティリティ ----

    /** 大文字・小文字・空白・句読点を除去して正規化 */
    private static String normalize(String s) {
        if (s == null)
            return "";
        return Normalizer.normalize(s, Normalizer.Form.NFC)
                .toLowerCase(Locale.ROOT)
                .replaceAll("[\\p{Punct}\\p{IsPunctuation}\\s]+", "");
    }

    /** 部分一致判定＋語中一致のガード */
    private static boolean match(String userNorm, String variantNorm) {
        if (variantNorm.length() < 3)
            return false;
        int idx = userNorm.indexOf(variantNorm);
        if (idx < 0)
            return false;

        int before = idx - 1;
        int after = idx + variantNorm.length();
        boolean leftKO = before >= 0 && isHangul(userNorm.codePointAt(before));
        boolean rightKO = after < userNorm.length() && isHangul(userNorm.codePointAt(after));
        boolean leftJA = before >= 0 && isJapanese(userNorm.codePointAt(before));
        boolean rightJA = after < userNorm.length() && isJapanese(userNorm.codePointAt(after));
        return !(leftKO || rightKO || leftJA || rightJA);
    }

    private static boolean isHangul(int cp) {
        return cp >= 0xAC00 && cp <= 0xD7A3;
    }

    private static boolean isJapanese(int cp) {
        return (cp >= 0x3040 && cp <= 0x309F) || (cp >= 0x30A0 && cp <= 0x30FF) || (cp >= 0x4E00 && cp <= 0x9FFF);
    }
}
