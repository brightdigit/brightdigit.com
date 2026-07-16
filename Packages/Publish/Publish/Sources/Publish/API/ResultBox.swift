/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Synchronization

/// A small Mutex-protected box used to hand a publishing result back from the
/// asynchronous pipeline `Task` to the synchronous `publish` method that waits
/// on a semaphore.
internal final class ResultBox<T: Sendable>: Sendable {
  private let storage = Mutex<Result<T, any Error & Sendable>?>(nil)

  internal var value: Result<T, any Error & Sendable>? {
    get { storage.withLock { $0 } }
    set { storage.withLock { $0 = newValue } }
  }
}
