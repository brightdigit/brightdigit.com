import Foundation

enum SocialShares {
  static let shares: [SocialShare] = [
    TwitterSocialShare(),
    LinkedInSocialShare(),
    BufferSocialShare(),
    EmailSocialShare()
  ]
}
