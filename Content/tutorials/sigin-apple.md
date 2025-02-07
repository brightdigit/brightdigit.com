---
title: How Does Sign-In With Apple Workout in the Real World?
date: 2025-05-09 00:00
description: Lorem ipsum
featuredImage: /media/articles/scale-ios-app/overgrown-green-staircase-in-the-forest.jpg
---

The Apple Watch presents unique authentication challenges - the small screen makes traditional login flows impractical. Today we'll talk about:
* How to setup Sign In With Apple with Vapor
* How to setup Sign In With Apple in a SwiftUI app
* How to enable Sign In With Apple on the Apple Watch Simulator

## Understanding JWT Authentication

Before diving into the implementation, it's important to understand JSON Web Tokens (JWT). JWTs are a secure way to transmit information between parties as a JSON object. They are commonly used in authentication systems because they are digitally signed, which ensures the data hasn't been tampered with.

A JWT consists of three parts:
- A header containing metadata
- A payload with the actual data (claims)
- A signature to verify authenticity

For a detailed guide on working with JWTs in Swift, check out the comprehensive [JWTKit tutorial on Swift on Server](https://swiftonserver.com/jwt-kit/).

## Server Implementation

Before implementing Sign in with Apple, you need to configure your App ID in Apple Developer Portal:
   - Enable Sign in with Apple capability
   - Note your Services ID and Bundle ID

### Vapor 

Verify Apple's JWT tokens directly:

```swift
// setting up our JWT signer
app.jwt.signers.use(JWTSigner.hs512(key: jwtSecret))

// On request, verify the JWT token
let tokenValue = try await req.jwt.apple
    .verify(body.token, applicationIdentifier: nil)
    .map(\.subject.value)
    .get()
```

### Hummingbird 
Handle both Apple's JWKs and HMAC keys:

```swift
internal extension JWTKeyCollection {
    private static let appleIDJWKSurl = "https://appleid.apple.com/auth/keys"

    internal init(
        configuration: SecurityConfiguration, 
        httpClient: HTTPClient = .shared
    ) async throws {
        try await self.init(
            jwksURL: Self.appleIDJWKSurl,
            // your own HMAC key
            hmacKey: .init(from: configuration.secretKey),
            httpClient: httpClient
        )
    }

    private init(
        jwksURL: String, 
        hmacKey: HMACKey, 
        httpClient: HTTPClient = .shared
    ) async throws {
        self.init()
        // add the Apple JWKS to the JWTKeyCollection
        let request = HTTPClientRequest(url: jwksURL)
        let jwksResponse: HTTPClientResponse = try await httpClient.execute(
            request
        )
        let jwksData = try await jwksResponse.body.collect(upTo: 1_000_000)
        let jwks = try JSONDecoder().decode(JWKS.self, from: jwksData)
        try self.add(jwks: jwks)
        // add your own HMAC key to the JWTKeyCollection
        self.add(hmac: hmacKey, digestAlgorithm: .sha512)
    }
}
```

Using OpenAPI generator:

```swift
internal func createUser(
    _ input: Operations.createUser.Input
) async throws -> Operations.createUser.Output {
    guard case let .json(userBody) = input.body else {
        return .undocumented(statusCode: 400, .init())
    }

    // verify the JWT token
    let jwt = try await keyCollection.verify(
        userBody.appleIdentityToken, 
        as: AppleIdentityToken.self
    )

    // list of audiences to verify
    let audiences = [
        // iPhone app
        "com.brightdigit.Bitness",
        // Apple Watch app
        "com.brightdigit.Bitness.watchkitapp",
        // Web Site
        "com.brightdigit.Bitness.AuthenticationServices",
    ]

    var verifiedAudience: String?
    var errors: [any Error] = []
    
    // verify the audience
    for audience in audiences {
        do {
            try jwt.audience.verifyIntendedAudience(includes: audience)
            verifiedAudience = audience
            break
        } catch {
            errors.append(error)
        }
    }

    // if the audience is not verified, return 401 Unauthorized
    guard let verifiedAudience else {
        return Operations.createUser.Output.undocumented(
            statusCode: 401, 
            .init()
        )
    }
}
```

## SwiftUI Implementation
Our main authentication view conditionally renders different buttons based on the environment:

```swift
struct AuthenticationView: View {
    @StateObject private var object: AuthenticationObject
    private var service: AuthenticationService
    @State private var isReady = false
    @State private var loginResponse: LoginResponse?

    var body: some View {
        VStack {
            SignInWithAppleButton(.signUp,
                // update the ASAuthorizationOpenIDRequest with the correct scopes
                onRequest: object.appleSignInWithRequest,
                // handle the failure case or send the credentials to the server
                onCompletion: { result in
                    object.appleSignInCompletedWith(result)
                }
            )
        }
    }
}
```

Sign in with Apple provides an elegant solution, but creates development hurdles since it doesn't work in the simulator.

## Simulator Authentication Implementation

The simulator authentication uses a file-based approach with a custom `SimulatorLoginButton`:

```swift
/// Protocol defining the behavior of a file observer for simulator authentication
protocol FileObserving {
    
    /// The most recent data read from the observed file
    var lastData: Data? { get }
    
    /// Initialize a file observer
    /// - Parameters:
    ///   - fileURL: The URL of the file to observe
    ///   - shouldBeReady: Closure that determines if the data is valid for authentication
    init(fileURL: URL, shouldBeReady: @escaping @Sendable (Data) async -> Bool)
    
    /// Called periodically to check for file changes
    /// - Parameter date: The current date when the timer fires
    func onTimer(_ date: Date)
}

extension FileObserving {
    var isReady: Bool {
        lastData != nil
    }
}

struct SimulatorLoginButton: View {
    let action: @Sendable (Data?) -> Void
    let timerPublisher = Timer.publish(
        every: 1.0,
        on: .main,
        in: .default
    ).autoconnect()
    let observer: any FileObserving

    var body: some View {
        Button(
            "Login", 
            action: {
                action: {
                    if let lastData = observer.lastData {
                        self.action(lastData)
                    }
                }
            }
        )
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
            observer: .init(fileURL: fileURL, shouldBeReady: onData),
            action: action
        )
    }
}
```

### Server-Side Simulator Support

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

Let's now add the simulator authentication to our SwiftUI app.

```swift
struct AuthenticationView: View {
    @StateObject private var object: AuthenticationObject
    private var service: AuthenticationService
    @State private var isReady = false
    @State private var loginResponse: LoginResponse?

    var body: some View {
        VStack {
            Spacer()
            #if os(watchOS) && targetEnvironment(simulator)
            SimulatorLoginButton(
                fileURL: FileManager.default.temporaryDirectory
                .appending(path: "com.brightdigit.Bitness.watchkitapp"),
                onData: { data in
                guard let token = String(data: data, encoding: .utf8) else {
                    return false
                }

                await tokenContainer.setToken(token, isTemporary: true)
                Self.logger.debug("Testing Token: \(token)")
                let user = try? await bitness.getUser()

                return user != nil
                },
                action: { data in
                guard let token = data.flatMap({ String(data: $0, encoding: .utf8) }) else {
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
            Spacer()
        }
    }
}
```

## Using SimulatorServices

We leverage the [SimulatorServices](https://github.com/brightdigit/SimulatorServices) library to interact with iOS simulators. This provides a clean API for:

- Finding active simulators
- Accessing simulator container paths
- Managing simulator file systems

The library handles the complexities of running `simctl` commands and parsing their output, making simulator authentication development significantly easier.

## Development Workflow

1. User authenticates through web interface
2. Server writes auth data to simulator filesystem using SimulatorServices
3. `SimulatorLoginButton` watches for file changes
4. App processes auth data and completes login

## Security Considerations

- Simulator authentication only in DEBUG builds
- Data written to temporary locations
- File permissions properly managed
- Server-side token validation