// swift-format-ignore-file
// swiftlint:disable all
import Foundation

@available(*, deprecated, message: "Scheduled for removal; do not use in new code.")
public struct MailchimpCampaignRequest {
  public init(listID: String) {
    self.listID = listID
  }

  let listID: String
}
