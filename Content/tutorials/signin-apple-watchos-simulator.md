---
title: Implementing Sign in with Apple in the watchOS Simulator
date: 2025-03-11 00:00
description: Learn how to implement and test Sign in with Apple functionality in the watchOS simulator
featuredImage: /media/tutorials/signin-apple-watchos-simulator/featured-image.webp
subscriptionCTA: If you want to learn more about building a Full Stack Swift application such as gBeat, sign up for the newsletter to get notified of our latest articles.
---

With [_Sign in with Apple_ implemented on the server and client](/tutorials/full-stack-sign-in-with-apple/), we were ready to begin developing our fitness app for the Apple Watch. However, we quickly ran into issues with developing for the Apple Watch:

<video width="100%" autoplay muted loop>
  <source src="/media/tutorials/signin-apple-watchos-simulator/Waiting-For-Apple-Watch.mov" type="video/mp4">
  <source src="/media/tutorials/signin-apple-watchos-simulator/Waiting-For-Apple-Watch.webm" type="video/webm">
  Your browser does not support the video tag.
</video>

Although we are able to use the watchOS simulator, unfortunately the simulator doesn't support _Sign In With Apple_.
This basically blocked the workflow in using the app. 

But if we have access to the server and the simulator on the same machine we can work around this. **We can write to the simulator directly from the server.** In this guide we will show you how to:

* Set up a **simulator-specific authentication flow**
* Implement **file-based authentication** for testing on simulator
* Handle simulator authentication **on both client and server sides**

## The Simulator Challenge

As stated, _Sign In With Apple_ doesn't work in the watchOS simulator environment, which creates development hurdles. To overcome this, we'll implement a file-based authentication system that:

1. **Server writes a file** to the simulator to transfer authentication data
2. **Simulator watches for file** changes to trigger authentication
3. **Validates the authentication** data before proceeding

## File Observation Implementation


Let's define **the name of the file** which will be used to save the authentication data. We'll share this with the server and the SwiftUI view.


```swift
enum SimulatorAuthentication {  
  static let fileName = "com.brightdigit.Bitness"
}
```

Let's define the protocols and classes needed for file-based authentication.  Here we created a protocol to watch the file for changes called `FileObserving`:

```swift
/// Protocol defining the behavior of a file observer for simulator authentication
protocol FileObserving {
  // publisher which returns the data when it's ready
  var dataPublisher: AnyPublisher<Data?, Never> { get }
}

/// Uses a timer to periodically reads the file if it's there
internal final class TimerObserver: FileObserving {
    // the data publisher which will publish the data
    let dataPublisher: AnyPublisher<Data?, Never>

    // creates the TimerObserver
    internal convenience init(
      fileURL: URL,
      checkEvery seconds: TimeInterval = 0.1,
      shouldBeReady: @escaping @Sendable (Data) async -> Bool
    ) {
      // create the new publisher
      let timerPublisher = Timer.publish(every: seconds, on: .main, in: .default).autoconnect()
      // initialize the object
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


  extension Publisher where Failure == Never {
    // read the file and filter the data based on the closure
     func readFile(
      at fileURL: URL,
      if shouldBeReady: @escaping @Sendable (Data) async -> Bool
    ) -> some Publisher<Data?, Never> {
      return
        self
        .readFile(at: fileURL)
        .filterAsync(shouldBeReady)

    }

    // read the file, filter duplicates, and return the data
     private func readFile<T: UniqueData>(
      at fileURL: URL
    ) -> some Publisher<Data, Never> {
      return self.compactMap { _ -> Data? in
        try? Data(contentsOf: fileURL)
      }
      .removeDuplicates()
      .map(\.data)
    }

  }

  extension Publisher where Output == Data {
    // filter the data based on the closure
     fileprivate func filterAsync(_ closure: @escaping @Sendable (Data) async -> Bool)
      -> some Publisher<
        Data?, Failure
      >
    {
      self.map { (data: Data) in
      // test whether the data is valid for authentication
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
```

Thanks to [Rob Napier for the Swift 6 implementation of the `Future` publisher](https://stackoverflow.com/a/78894560/97705):

```swift
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

Alright now we can create a custom button for simulator authentication:

```swift
  struct SimulatorLoginButton: View {
     let action: @Sendable (Data) -> Void
     var observer: any FileObserving
    @State  var lastData: Data?

    internal var body: some View {
      Button(
        // whatever text you want
        "Login",
        action: {
          // if there is data, call the action
          if let lastData = lastData {
            self.action(lastData)
          }
        }
      )
      .onReceive(
        // receive the data from the observer
        self.observer.dataPublisher,
        perform: { data in
          Task { @MainActor in
            self.lastData = data
          }
        }
      )
      // disable the button if there is no data
      .disabled(lastData == nil)

    }

    internal init(
      fileURL: URL,
      onData: @escaping @Sendable (Data) async -> Bool,
      action: @escaping @Sendable (Data) -> Void
    ) {
      self.init(
        observer: FileObserver(fileURL: fileURL, shouldBeReady: onData), 
        action: action
      )
    }

    internal init(
      observer: any FileObserving, 
      action: @escaping @Sendable (Data) -> Void
    ) {
      self.action = action
      self.observer = observer
    }
  }
```

## Server-Side Implementation Using SimulatorServices

The server needs to handle writing the authentication data to simulator containers. In this case, we'll use the [SimulatorServices](https://github.com/brightdigit/SimulatorServices) library to interact with watchOS simulators. This provides a clean API for:

- Finding active simulators
- Accessing simulator container paths

The library handles the complexities of running `simctl` commands and parsing their output, making simulator authentication development significantly easier.

In this case find the directories where the app's data directory is located on booted simulators and write our authentication data to them.

```swift
extension SimCtl {
  struct MissingSimulatorError: Error {
    let appBundleIdentifier: String
    let type: ContainerID
  }

  /// Saves the token to all booted simulator devices in the container directory.
  /// - Parameters:
  ///   - token: Authentication Token
  ///   - relativePath: relative path inside the container.
  ///   - appBundleIdentifier: Application Bundle Identifier.
  ///   - type: Container Type
  ///   - deviceState: Filter Devices by Device State
  internal func saveToSimulators(
    _ token: String,
    toRelativePath relativePath: String,
    appBundleIdentifier: String,
    type: ContainerID = .data,
    deviceState: DeviceState? = .booted
  ) async throws {
    // get container paths
    let containerPaths = try await self.fetchContainerPaths(
      appBundleIdentifier: appBundleIdentifier,
      type: type
    )

    // define file paths
    let filePaths = containerPaths.map { $0.appending("/" + relativePath) }

    // throw error is there's no simulator running
    guard !filePaths.isEmpty else {
      throw MissingSimulatorError(
        appBundleIdentifier: appBundleIdentifier,
        type: type
      )
    }

    // write the token to each simulator's path
    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
      for filePath in filePaths {
        taskGroup.addTask {
          try token.write(
            to: URL(fileURLWithPath: filePath),
            atomically: true,
            encoding: .utf8
          )
        }
      }

      return try await taskGroup.reduce(()) { _, _ in }
    }
  }

  /// Fetches container paths for a specific application.
  /// - Parameters:
  ///   - appBundleIdentifier: Application Bundle Identifier
  ///   - type: Container Type
  ///   - deviceState: Filter Devices by Device State
  /// - Returns: A list of paths to all containers based on the application identifier.
  internal func fetchContainerPaths(
    appBundleIdentifier: String,
    type: ContainerID,
    deviceState: DeviceState? = .booted
  ) async throws -> [Path] {
    try await withThrowingTaskGroup(of: Path?.self) { taskGroup in
      // run `xcrun simctl list devices`
      let list = try await self.run(List())
      // filter the devices which match the `deviceState`
      let devices: [Device]
      let listDevices = list.devices.values.flatMap { $0 }
      // if the device state is set, filter the devices
      if let deviceState {
        devices =
          listDevices
          .filter { $0.state == deviceState }
      } else {
        devices = listDevices
      }
      for device in devices {
        // for each device run
        //  `xcrun simctl get_app_container {device.udid} {appBundleIdentifier} {type}`
        // example:
        //  `xcrun simctl get_app_container E294F724-10D0-422E-894C-745791166D86 com.bpmsync.GBeat.watchkitapp data`
        let subcommand = GetAppContainer(
          appBundleIdentifier: appBundleIdentifier,
          container: type,
          simulator: .id(device.udid)
        )
        taskGroup.addTask {
          // get the app container path
          do {
            return try await self.run(subcommand)
          } catch GetAppContainer.Error.missingData {
            return nil
          }
        }
      }

      return try await taskGroup.reduce(into: [Path]()) { paths, path in
        // if the path is not nil, append it to the paths
        if let path {
          paths.append(path)
        }
      }
    }
  }
}
```

Now that we have the server-side implementation for saving the authentication data to the simulator, we can integrate it into our login call. Here's an example of how we can do this with a `signedToken`:

```swift
    let signedToken : String

    // save the token to the simulator when we are running the server on macOS in DEBUG mode
    #if os(macOS) && DEBUG
      let simctl = SimCtl()
      do {
        try await simctl.saveToSimulators(
          signedToken,
          toRelativePath: "tmp/\(SimulatorAuthentication.fileName)",
          // the app bundle identifier on the Apple Watch
          appBundleIdentifier: "com.brightdigit.Bitness.watchkitapp"
        )
      } catch let error as SimCtl.MissingSimulatorError {
        print("No simulators setup.")
      }
    #endif
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
            // only show the login button in the watchOS simulator
            #if os(watchOS) && targetEnvironment(simulator)
            SimulatorLoginButton(
                isReady: $isReady,
                fileURL: FileManager.default.temporaryDirectory
                    .appending(path: SimulatorAuthentication.fileName),
                onData: { data in
                  // get the token from the data
                  let token = String.init(decoding: data, as: UTF8.self)
                  // set the token to the token container temporarily
                  await tokenContainer.setToken(token, isTemporary: true)
                  // see if you can login with the token
                  let user = try? await bitness.getUser()
                  // return whether the login was successful
                  return user != nil
                },
                action: { data in 
                  // get the token from the data
                  let token: String = .init(decoding: data, as: UTF8.self)
                  // set the token to the token container permanently
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

## Last Thoughts

Implementing _Sign In With Apple_ in the watchOS simulator requires careful consideration of both development workflow and security. The solution we've outlined provides a practical approach that enables efficient testing while maintaining proper security practices.

When implementing this solution, remember these critical points:

- Only enable **simulator authentication in DEBUG builds**
- Use **temporary** file locations for authentication data
- **Clean up** authentication files after use

By following these guidelines, you can easily develop and test _Sign In With Apple_ functionality in your watchOS applications while maintaining security.

The workflow is straightforward: authenticate through your development interface, let the server handle the simulator file writing, and watch as the `SimulatorLoginButton` manages the authentication process in your app. This creates a development environment that closely mirrors the production experience while providing the flexibility needed for efficient testing.

<video width="100%" autoplay muted loop>
  <source src="/media/tutorials/signin-apple-watchos-simulator/SignInWithApple-watchOSSimulator.mov" type="video/mp4">
  <source src="/media/tutorials/signin-apple-watchos-simulator/SignInWithApple-watchOSSimulator.webm" type="video/webm">
  Your browser does not support the video tag.
</video>

Next steps could include:

- using a hash to compare Data
- implement file observation using [DispatchSource](https://swiftrocks.com/dispatchsource-detecting-changes-in-files-and-folders-in-swift)

For more information about watchOS development and authentication patterns, check out our [other tutorials](/tutorials) and [the official Apple documentation on _Sign In With Apple_ implementation.](https://developer.apple.com/documentation/AuthenticationServices/)

