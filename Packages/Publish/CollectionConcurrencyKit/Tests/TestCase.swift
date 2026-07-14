/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE.md file for details
*/

import XCTest

@MainActor
class TestCase: XCTestCase {
    let array = Array(0..<5)
    let collector = Collector()

    static func verifyErrorThrown<T>(
        in file: StaticString = #filePath,
        at line: UInt = #line,
        from closure: (Error) async throws -> T
    ) async {
        let expectedError = IdentifiableError()

        do {
            let result = try await closure(expectedError)
            XCTFail("Unexpected result: \(result)", file: file, line: line)
        } catch let error as IdentifiableError {
            XCTAssertEqual(error, expectedError, file: file, line: line)
        } catch {
            XCTFail("Incorrect error thrown: \(error)", file: file, line: line)
        }
    }

    @MainActor
    func runAsyncTest(
        named testName: String = #function,
        in file: StaticString = #filePath,
        at line: UInt = #line,
        withTimeout timeout: TimeInterval = 10,
        test: @escaping @Sendable ([Int], Collector) async throws -> Void
    ) {
        // This method is needed since Linux doesn't yet support async test methods.
        let thrownError = LockedError()
        let expectation = expectation(description: testName)
        let array = self.array
        let collector = self.collector

        Task.detached {
            do {
                try await test(array, collector)
            } catch {
                thrownError.value = error
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: timeout)

        if let error = thrownError.value {
            XCTFail("Async error thrown: \(error)", file: file, line: line)
        }
    }
}

extension TestCase {
    // Note: This is not an actor because we want it to execute concurrently.
    // Thread safety is provided manually by serializing all mutable access
    // through `queue`, so the unchecked Sendable conformance is sound.
    final class Collector: @unchecked Sendable {
        var values = [Int]()
        private let queue = DispatchQueue(label: "Collector")

        func collect(_ value: Int) async {
            await withCheckedContinuation { continuation in
                queue.async {
                    self.values.append(value)
                    continuation.resume()
                }
            } as Void
        }

        func collectAndTransform(_ value: Int) async -> String {
            await collect(value)
            return String(value)
        }

        func collectAndDuplicate(_ value: Int) async -> [Int] {
            await collect(value)
            return [value, value]
        }

        func tryCollect(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws {
            try await withCheckedThrowingContinuation { continuation in
                queue.async {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    }

                    self.values.append(value)
                    continuation.resume()
                }
            } as Void
        }

        func tryCollectAndTransform(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws -> String {
            try await tryCollect(value, throwError: error)
            return String(value)
        }

        func tryCollectAndDuplicate(
            _ value: Int,
            throwError error: Error? = nil
        ) async throws -> [Int] {
            try await tryCollect(value, throwError: error)
            return [value, value]
        }
    }
}

private extension TestCase {
    struct IdentifiableError: Error, Equatable {
        let id = UUID()
    }
}

// A tiny lock-protected box so the async `Task` can report a thrown error
// back to the synchronous `runAsyncTest` body without capturing `self`.
private final class LockedError: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: Error?

    var value: Error? {
        get { lock.withLock { storage } }
        set { lock.withLock { storage = newValue } }
    }
}
