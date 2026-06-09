import Foundation
import Plot
import Publish

public protocol MetadataAttached {
  static var metadata: WebsiteMetadata { get }
}
