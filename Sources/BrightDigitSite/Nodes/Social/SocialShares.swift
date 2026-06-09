import Foundation

internal enum SocialShares {
  internal static let shares: [SocialShare] = [
    TwitterSocialShare(),
    LinkedInSocialShare(),
    BufferSocialShare(),
    EmailSocialShare(),
  ]
}
