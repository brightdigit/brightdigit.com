/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Synchronization

/// A general-purpose reference box that serializes access to its value behind a
/// Mutex. It lets tests observe values that are written from within `@Sendable`
/// publishing-step closures without tripping strict-concurrency diagnostics.
final class LockIsolated<Value: Sendable>: Sendable {
    private let storage: Mutex<Value>

    init(_ value: Value) {
        storage = Mutex(value)
    }

    var value: Value {
        get { storage.withLock { $0 } }
        set { storage.withLock { $0 = newValue } }
    }

    func withValue<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        try storage.withLock { try body(&$0) }
    }
}
