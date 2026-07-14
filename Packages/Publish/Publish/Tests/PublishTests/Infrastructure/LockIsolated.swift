/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Foundation

/// A general-purpose reference box that serializes access to its value behind a
/// lock. It lets tests observe values that are written from within `@Sendable`
/// publishing-step closures without tripping strict-concurrency diagnostics.
/// The unchecked Sendable conformance is justified by the lock guarding all
/// access to `_value`.
final class LockIsolated<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value

    init(_ value: Value) {
        _value = value
    }

    var value: Value {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }

    func withValue<T>(_ body: (inout Value) throws -> T) rethrows -> T {
        try lock.withLock { try body(&_value) }
    }
}
