/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// Protocol that all `Website.SectionID` implementations must conform to.
public protocol WebsiteSectionID: Decodable, Hashable, CaseIterable, RawRepresentable, Sendable
where RawValue == String {}
