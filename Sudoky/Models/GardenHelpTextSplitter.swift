import Foundation

enum BookletTextSplitter {
    static func split(
        _ text: String,
        availableHeight: CGFloat,
        minimumLineHeight: CGFloat,
        fits: (String) -> Bool
    ) -> [String] {
        guard !text.isEmpty else { return [""] }
        guard availableHeight >= minimumLineHeight else {
            // Keep the complete text together when the viewport cannot fit one line.
            return [text]
        }

        // Character fallback is safe only when every source character can fit on its own.
        guard text.map(String.init).allSatisfy(fits) else { return [text] }

        var result: [String] = []
        var current = ""
        for sentence in sentencePieces(in: text) {
            if fits(current + sentence) {
                current += sentence
                continue
            }

            if !current.isEmpty {
                result.append(current)
                current = ""
            }

            if fits(sentence) {
                current = sentence
                continue
            }

            for token in wordTokens(in: sentence) {
                append(token, fits: fits, current: &current, result: &result)
            }
        }

        if !current.isEmpty {
            result.append(current)
        }
        assert(result.joined() == text, "Garden help pagination must preserve every source character")
        assert(result.allSatisfy { !$0.isEmpty }, "Garden help pagination must not create empty pages")
        return result.isEmpty ? [text] : result
    }

    private static func sentencePieces(in text: String) -> [String] {
        let end = text.endIndex
        var pieces: [String] = []
        var start = text.startIndex
        var cursor = start
        let closingCharacters: Set<Character> = ["»", "”", "’", "\"", "'", ")", "]"]

        while cursor < end {
            guard ".!?".contains(text[cursor]) else {
                cursor = text.index(after: cursor)
                continue
            }

            var boundary = text.index(after: cursor)
            while boundary < end && ".!?".contains(text[boundary]) {
                boundary = text.index(after: boundary)
            }
            while boundary < end && closingCharacters.contains(text[boundary]) {
                boundary = text.index(after: boundary)
            }
            while boundary < end && text[boundary].isWhitespace {
                boundary = text.index(after: boundary)
            }

            pieces.append(String(text[start..<boundary]))
            start = boundary
            cursor = boundary
        }

        if start < end {
            pieces.append(String(text[start..<end]))
        }
        return pieces.isEmpty ? [text] : pieces
    }

    private static func wordTokens(in text: String) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: #"\S+\s*"#) else {
            return Array(text).map(String.init)
        }

        let source = text as NSString
        let matches = expression.matches(in: text, range: NSRange(location: 0, length: source.length))
        let tokens = matches.map { source.substring(with: $0.range) }
        guard !tokens.isEmpty, tokens.joined() == text else {
            return Array(text).map(String.init)
        }
        return tokens
    }

    private static func append(
        _ token: String,
        fits: (String) -> Bool,
        current: inout String,
        result: inout [String]
    ) {
        if fits(current + token) {
            current += token
            return
        }

        if !current.isEmpty {
            result.append(current)
            current = ""
        }

        if fits(token) {
            current = token
            return
        }

        for character in token.map(String.init) {
            if fits(current + character) {
                current += character
            } else {
                if !current.isEmpty {
                    result.append(current)
                }
                current = character
            }
        }
    }
}
