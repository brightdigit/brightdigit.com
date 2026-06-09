internal enum TutorialPostable: Postable {
  internal static let sectionH1 = "Latest Developer Tutorials"
  internal static let sectionTitle = "Tutorials – Learn how build better Swift apps"
  internal static let sectionDescription =
    "Read our Tutorials and Development Articles on how to build the best apps you can for Apple Devices"

  internal static let twitterSource: String = "leogdion"
}

internal typealias TutorialItem = PostItem<TutorialPostable>
