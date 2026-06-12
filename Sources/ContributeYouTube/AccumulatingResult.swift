// swift-format-ignore-file
// swiftlint:disable all
@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public struct AccumulatingResult<T> {
  public let nextPageToken: String
  public let items: [T]
}
