/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// Protocol that all `Website.ItemMetadata` implementations must conform to.
public typealias WebsiteItemMetadata = Decodable & Hashable & Sendable
