---
title: Testing Sign in with Apple in the watchOS Simulator
date: 2025-05-09 00:00
description: Learn how to implement and test Sign in with Apple functionality in the watchOS simulator
featuredImage: /media/articles/watchos-dev/apple-watch-development.jpg
---

Testing Sign in with Apple in the simulator environment presents unique challenges, especially for watchOS development. This guide will show you how to:
* Set up a simulator-specific authentication flow
* Implement file-based authentication for testing
* Handle simulator authentication on both client and server sides

## The Simulator Challenge

Sign in with Apple doesn't work in the simulator environment, which creates development hurdles. To overcome this, we'll implement a file-based authentication system that:
1. Uses a file to transfer authentication data
2. Watches for file changes to trigger authentication
3. Validates the authentication data before proceeding

## File Observation Implementation

First, let's define the protocols and classes needed for file-based authentication:

```swift
  /// Protocol defining the behavior of a file observer for simulator authentication
  protocol FileObserving {
    var dataPublisher: AnyPublisher<Data?, Never> { get }
  }


internal final class FileObserver: Loggable, FileObserving {
    let dataPublisher: AnyPublisher<Data?, Never>

    nonisolated static var loggingCategory: BitnessLoggingSystem.Category {
      .simulator
    }

    private var timerCancellable: AnyCancellable?
    internal private(set) var lastData: Data?
    internal convenience init(
      fileURL: URL,
      checkEvery seconds: TimeInterval = 0.1,
      shouldBeReady: @escaping @Sendable (Data) async -> Bool
    ) {
      let timerPublisher = Timer.publish(every: seconds, on: .main, in: .default).autoconnect()
      self.init(
        fileURL: fileURL,
        timerPublisher: timerPublisher,
        shouldBeReady: shouldBeReady
      )
    }

    private init<PublisherType: Publisher>(
      fileURL: URL,
      timerPublisher: PublisherType,
      shouldBeReady: @escaping @Sendable (Data) async -> Bool
    ) where PublisherType.Failure == Never {
      Self.logger.debug("Watching \(fileURL)")

      dataPublisher = timerPublisher.readFile(
        at: fileURL,
        if: shouldBeReady
      )
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()

    }

  }
  ```

The method `readFile` does some Combine magic to read the file, if the data changes and it's valid for logging in, return the data. Which I broke down here:

```swift
  fileprivate struct DataWithHash: Sendable, Codable, Equatable, UniqueData {
    let data: Data
    let hash: UInt64

    init?(contentsOf url: URL) {
      self.init(contentsOf: url, hashBy: Self.fnv1aHash)
    }

    init?(contentsOf url: URL, hashBy hash: @escaping @Sendable (Data) -> UInt64) {
      guard let data = try? Data(contentsOf: url) else {
        return nil
      }
      self.init(data: data, hashBy: hash)
    }

    init(data: Data, hashBy hash: @escaping @Sendable (Data) -> UInt64 = Self.fnv1aHash) {
      self.init(
        data: data,
        hash: hash(data)
      )
    }

    init(data: Data, hash: UInt64) {
      self.data = data
      self.hash = hash
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.hash == rhs.hash
    }
  }

  extension Data {
    /// Implementation of the FNV-1a (Fowler-Noll-Vo) hash algorithm
    /// This is a non-cryptographic hash function designed for fast hash table lookup
    fileprivate var fnv1aHash: UInt64 {
      // FNV offset basis for 64-bit - this is a required constant
      // that helps provide better distribution of hash values
      var hash: UInt64 = 14_695_981_039_346_656_037
      
      for byte in self {
        // XOR the current byte with the hash (FNV-1a variation)
        // This operation helps in producing different hash values
        // even for similar inputs
        hash ^= UInt64(byte)
        
        // Multiply by the FNV prime for 64-bit - this is a required constant
        // The prime was chosen for its multiplication properties
        // that help in spreading the bits of the hash value
        // &*= is used for overflow multiplication
        hash &*= 1_099_511_628_211
      }
      return hash
    }
  }

  extension Publisher where Output == Data {
    fileprivate func filterAsync(_ closure: @escaping @Sendable (Data) async -> Bool)
      -> some Publisher<
        Data?, Failure
      >
    {
      self.map { (data: Data) in
        SendingFuture { promise in
          Task {
            let bool = await closure(data)
            promise(.success(bool ? data : nil))
          }
        }
      }
      .switchToLatest()
    }
  }

  protocol UniqueData: Equatable {
    init?(contentsOf url: URL)
    var data: Data { get }
  }

  extension Publisher where Failure == Never {

    private func readFile<T: UniqueData>(
      at fileURL: URL,
      with _: T.Type
    ) -> some Publisher<Data, Never> {
      return self.compactMap { _ -> T? in
        T(contentsOf: fileURL)
      }
      .removeDuplicates()
      .map(\.data)
    }

    internal func readFile(
      at fileURL: URL,
      if shouldBeReady: @escaping @Sendable (Data) async -> Bool
    ) -> some Publisher<Data?, Never> {
      return
        self
        .readFile(at: fileURL, with: DataWithHash.self)
        .filterAsync(shouldBeReady)

    }
  }

```

```swift
/// From Rob Napier https://stackoverflow.com/a/78894560/97705
  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  fileprivate final class SendingFuture<Output, Failure: Error>: Publisher, Sendable {
    public typealias Promise = @Sendable (Result<Output, Failure>) -> Void

    private let attemptToFulfill: @Sendable (@escaping Promise) -> Void

    public init(_ attemptToFulfill: @Sendable @escaping (@escaping Promise) -> Void) {
      self.attemptToFulfill = attemptToFulfill
    }

    public func receive<S>(subscriber: S)
    where S: Subscriber, Failure == S.Failure, Output == S.Input, S: Sendable {
      let subscription = SendingSubscription(
        subscriber: subscriber, attemptToFulfill: attemptToFulfill)
      subscriber.receive(subscription: subscription)
    }

    private final class SendingSubscription<S: Subscriber>: Subscription
    where S.Input == Output, S.Failure == Failure, S: Sendable {
      private var subscriber: S?

      init(subscriber: S, attemptToFulfill: @escaping (@escaping Promise) -> Void) {
        self.subscriber = subscriber
        attemptToFulfill { result in
          switch result {
          case .success(let output):
            _ = subscriber.receive(output)
            subscriber.receive(completion: .finished)
          case .failure(let failure):
            subscriber.receive(completion: .failure(failure))
          }
        }
      }

      func request(_ demand: Subscribers.Demand) {}

      func cancel() {
        subscriber = nil
      }
    }
  }
```

## Simulator Login Button

Create a custom button for simulator authentication:

```swift
struct SimulatorLoginButton: View {
    let action: @Sendable (Data?) -> Void
    let timerPublisher = Timer.publish(
        every: 1.0,
        on: .main,
        in: .default
    ).autoconnect()
    let observer: any FileObserving

    var body: some View {
        Button("Login") {
            if let lastData = observer.lastData {
                self.action(lastData)
            }
        }
        .disabled(!observer.isReady)
        .onReceive(timerPublisher) { input in
            observer.onTimer(input)
        }
    }

    init(
        isReady: Binding<Bool>,
        fileURL: URL,
        onData: @escaping @Sendable (Data) async -> Bool,
        action: @escaping @Sendable (Data?) -> Void
    ) {
        self.init(
            isReady: isReady,
            observer: FileObserver(fileURL: fileURL, shouldBeReady: onData),
            action: action
        )
    }
}
```

## Server-Side Implementation

The server needs to handle writing authentication data to simulator containers:

```swift
extension AuthenticationController {
    #if DEBUG && os(macOS)
    static let simctl = SimCtl()

    public static func saveToSimulators(_ request: Request) async throws {
        guard let body = request.body.data else {
            throw Abort(.noContent)
        }

        let relativePath = "tmp/com.brightdigit.Bitness"
        
        let containerPaths = try await simctl.fetchContainerPaths(
            appBundleIdentifier: "com.brightdigit.Bitness.watchkitapp",
            type: .data
        )

        let filePaths = containerPaths.map { 
            $0.appending("/" + relativePath) 
        } + [
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Desktop/com.brightdigit.Bitness")
                .path
        ]

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for filePath in filePaths {
                taskGroup.addTask {
                    let fileHandle: NIOFileHandle
                    request.logger.debug(
                        "Simulator Authentication: \(filePath)"
                    )
                    
                    try? await request.application.fileio
                        .remove(path: filePath, eventLoop: request.eventLoop)
                        .get()
                        
                    fileHandle = try await request.application.fileio
                        .openFile(
                            path: filePath,
                            mode: .write,
                            flags: .allowFileCreation(),
                            eventLoop: request.eventLoop
                        )
                        .get()
                        
                    try await request.application.fileio
                        .write(
                            fileHandle: fileHandle,
                            buffer: body,
                            eventLoop: request.eventLoop
                        )
                        .get()
                        
                    try fileHandle.close()
                }
            }

            return try await taskGroup.reduce(()) { _, _ in }
        }
    }
    #endif
}
```

## Integration in Your App

Update your authentication view to use the simulator login button when appropriate:

```swift
struct AuthenticationView: View {
    @StateObject private var object: AuthenticationObject
    private var service: AuthenticationService
    @State private var isReady = false

    var body: some View {
        VStack {
            #if os(watchOS) && targetEnvironment(simulator)
            SimulatorLoginButton(
                isReady: $isReady,
                fileURL: FileManager.default.temporaryDirectory
                    .appending(path: "com.brightdigit.Bitness"),
                onData: { data in
                    guard let token = String(data: data, encoding: .utf8) else {
                        return false
                    }
                    await tokenContainer.setToken(token, isTemporary: true)
                    let user = try? await bitness.getUser()
                    return user != nil
                },
                action: { data in
                    guard let token = data.flatMap({ 
                        String(data: $0, encoding: .utf8) 
                    }) else {
                        return
                    }
                    Task {
                        await tokenContainer.setToken(token, isTemporary: false)
                    }
                }
            )
            #else
            SignInWithAppleButton(.signUp,
                onRequest: object.appleSignInWithRequest,
                onCompletion: { result in
                    object.appleSignInCompletedWith(result)
                }
            )
            .frame(height: 40, alignment: .center)
            #endif
        }
    }
}
```

## Development Workflow

1. User initiates authentication through web interface or test endpoint
2. Server writes authentication data to simulator filesystem
3. SimulatorLoginButton detects file changes and validates data
4. App processes authentication data and completes login

## Security Considerations

Remember that this is for development only:
1. Only enable simulator authentication in DEBUG builds
2. Use temporary file locations
3. Implement proper file permissions
4. Clean up authentication files after use

## Using SimulatorServices

We use the [SimulatorServices](https://github.com/brightdigit/SimulatorServices) library to interact with iOS simulators. This provides a clean API for:

- Finding active simulators
- Accessing simulator container paths
- Managing simulator file systems

The library handles the complexities of running `simctl` commands and parsing their output, making simulator authentication development significantly easier.

## Next Steps

With simulator authentication in place, you can:
1. Implement automated testing
2. Add error handling and recovery
3. Extend the system for other authentication methods
4. Set up CI/CD pipelines with simulator testing 