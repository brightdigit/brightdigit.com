/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

internal protocol PublishingErrorConvertible {
  func publishingError(forStepNamed stepName: String?) -> PublishingError
}
