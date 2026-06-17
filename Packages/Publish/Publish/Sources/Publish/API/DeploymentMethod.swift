/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation
import Files

/// Type used to implement deployment functionality for a website.
/// When implementing reusable deployment methods that are vended as
/// frameworks or APIs, it's recommended to create them using static
/// factory methods.
public struct DeploymentMethod<Site: Website>: Sendable {
    /// Closure type used to implement the deployment method's main
    /// body. It's passed the `PublishingContext` of the current
    /// session, and can use that to create a dedicated deployment folder.
    public typealias Body = @Sendable (PublishingContext<Site>) throws -> Void

    /// The human-readable name of the deployment method.
    public var name: String
    /// The deployment method's main body. See `Body` for more info.
    public var body: Body

    /// Initialize a new deployment method.
    /// - parameter name: The method's human-readable name.
    /// - parameter body: The method's main body.
    public init(name: String, body: @escaping Body) {
        self.name = name
        self.body = body
    }
}
