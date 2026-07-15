import Foundation
import Publish

public struct ReadingTimeMetadata: Equatable, Sendable {
    public let minutes: Int
    public let words: Int
    public let timeMinutes: Double
}

public extension Item {
    /// The estimated reading time of the item, computed on demand from its
    /// rendered body. Reading time is a pure function of the body HTML and a
    /// fixed reading speed, so there is no cached/plugin state behind it.
    var readingTime: ReadingTimeMetadata {
        estimateTime(for: content.body.html, wordsPerMinute: 200)
    }
}

func estimateTime(for string: String, wordsPerMinute: Int) -> ReadingTimeMetadata {
    let words = countWords(string)
    let minutes = Double(words) / Double(wordsPerMinute)
    return ReadingTimeMetadata(
        minutes: Int(minutes.rounded()),
        words: words,
        timeMinutes: minutes
    )
}

private func countWords(_ string: String) -> Int {
    // Ideally we would be able to get a plain string (even if it's the original markdown) from Plot
    let plain = string.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression, range: nil)
    let separators = CharacterSet
        .whitespacesAndNewlines
        .union(.punctuationCharacters)
    let words = plain.components(separatedBy: separators)
        .filter { !$0.isEmpty }
    return words.count
}
