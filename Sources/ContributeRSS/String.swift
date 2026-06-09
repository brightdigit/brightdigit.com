import Foundation

extension String {
  public static let allParagraphTagRegex: NSRegularExpression = {
    do {
      return try NSRegularExpression(pattern: "<p[^>]*>(.*?)</p>", options: [])
    } catch {
      preconditionFailure("Invalid allParagraphTagRegex pattern: \(error)")
    }
  }()

  public func firstSummaryParagraph() -> String? {
    guard let htmlFirstParagraph = self.firstParagraphTag() else {
      return firstParagraphText()
    }

    return htmlFirstParagraph
  }

  public func firstParagraphText() -> String? {
    components(separatedBy: .newlines).first { line in
      !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  public func firstParagraphTag() -> String? {
    let range = NSRange(location: 0, length: self.utf16.count)

    guard
      let match = String.allParagraphTagRegex.firstMatch(
        in: self, options: [], range: range)
    else {
      return nil
    }

    return (self as NSString).substring(with: match.range(at: 1))
  }
}
