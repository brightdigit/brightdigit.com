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

## Setting Up Sign in with Apple on the Server

Before implementing Sign in with Apple, you need to:

1. Configure your App ID in Apple Developer Portal:
   - Enable Sign in with Apple capability
   - Note your Services ID and Bundle ID

2. Generate the necessary keys:
   - Create a Sign in with Apple private key in Developer Portal
   - Download the key and note the Key ID
   - Store these securely (we use environment variables)

3. Configure Vapor for JWT verification:
# How Does Sign In With Apple Work in the Real World?

The Apple Watch presents unique authentication challenges - the small screen makes traditional login flows impractical. Let's explore implementing Sign in with Apple for both server and client.

## Server Implementation

### Vapor Implementation

For Vapor, we can verify Apple's JWT tokens directly:

```swift
if let jwtSecret = jwtSecret {
    // setting up our JWT signer
    app.jwt.signers.use(JWTSigner.hs512(key: jwtSecret))
} else {
    app.logger.warning("Missing `JWT_SECRET` for Sign in with Apple.")
}

// Using the Apple JWT signer
let tokenValue = try await req.jwt.apple
    .verify(body.token, applicationIdentifier: nil)
    .map(\.subject.value)
    .get()
```

### Hummingbird Implementation

For Hummingbird, we need to handle both Apple's JWKs and our own HMAC keys:

```swift
internal extension JWTKeyCollection {
    private static let appleIDJWKSurl = "https://appleid.apple.com/auth/keys"

    internal init(
        configuration: SecurityConfiguration, 
        httpClient: HTTPClient = .shared
    ) async throws {
        try await self.init(
            jwksURL: Self.appleIDJWKSurl,
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
        let request = HTTPClientRequest(url: jwksURL)
        let jwksResponse: HTTPClientResponse = try await httpClient.execute(
            request, 
            timeout: .seconds(20)
        )
        let jwksData = try await jwksResponse.body.collect(upTo: 1_000_000)
        let jwks = try JSONDecoder().decode(JWKS.self, from: jwksData)
        try self.add(jwks: jwks)
        self.add(hmac: hmacKey, digestAlgorithm: .sha512)
    }
}
```

Using OpenAPI generator with Hummingbird:

```swift
internal func createUser(
    _ input: Operations.createUser.Input
) async throws -> Operations.createUser.Output {
    guard case let .json(userBody) = input.body else {
        return .undocumented(statusCode: 400, .init())
    }

    let jwt = try await keyCollection.verify(
        userBody.appleIdentityToken, 
        as: AppleIdentityToken.self
    )

    let audiences = [
        "com.brightdigit.Bitness",
        "com.brightdigit.Bitness.watchkitapp",
        "com.brightdigit.Bitness.AuthenticationServices",
    ]
    var verifiedAudience: String?
    var errors: [any Error] = []
    
    for audience in audiences {
        do {
            try jwt.audience.verifyIntendedAudience(includes: audience)
            verifiedAudience = audience
            break
        } catch {
            errors.append(error)
        }
    }

    guard let verifiedAudience else {
        return Operations.createUser.Output.undocumented(
            statusCode: 401, 
            .init()
        )
    }
    
    // Handle user creation...
}
```

## SwiftUI Implementation

Our main authentication view conditionally renders different buttons based on the environment:

```swift
struct AuthenticationView: View {
    @StateObject private var object: AuthenticationObject
    @State private var service: AuthenticationService?
    @State private var isReady = false
    @State private var loginResponse: LoginResponse?

    var body: some View {
        VStack {
            Spacer()
            Image("Wordmark")
                .resizable()
                .scaledToFit()
            Spacer()
            
            #if targetEnvironment(simulator)
            SimulatorLoginButton(
                isReady: $isReady,
                fileURL: FileManager.default.temporaryDirectory
                    .appending(path: "com.brightdigit.Bitness"),
                onData: { data in
                    guard let service = await service else {
                        assertionFailure("Missing service.")
                        return false
                    }
                    return await withCheckedContinuation { continuation in
                        service.loginWithData(data) { result in
                            switch result {
                            case let .success(loginResponse):
                                Task { @MainActor in
                                    self.loginResponse = loginResponse
                                }
                                continuation.resume(returning: true)
                            case .failure:
                                continuation.resume(returning: false)
                            }
                        }
                    }
                },
                action: { _ in
                    Task { @MainActor in
                        assert(loginResponse?.token != nil)
                        guard let accessToken = loginResponse?.token else {
                            return
                        }
                        await object.simulatorSaveToken(accessToken)
                    }
                }
            )
            .onReceive(object.serverPublisher) { service in
                self.service = service
                isReady = true
            }
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
        .background(Color.black)
    }
}
```

Sign in with Apple provides an elegant solution, but creates development hurdles since it doesn't work in the simulator.

## Simulator Authentication Implementation

The simulator authentication uses a file-based approach with a custom `SimulatorLoginButton`:

```swift
struct SimulatorLoginButton: View {
    @Binding var isReady: Bool
    let action: @Sendable (Data?) -> Void
    let timerPublisher = Timer.publish(
        every: 1.0,
        on: .main,
        in: .default
    ).autoconnect()
    var observer: FileObserver

    var body: some View {
        Button("Login", action: {
            action(observer.lastData)
        })
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

## Server-Side Implementation with Vapor

The server handles simulator authentication by writing tokens directly to the simulator's filesystem:

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

        request.logger.debug("Found \(containerPaths.count) paths.")

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

## Using SimulatorServices

We leverage the [SimulatorServices](https://github.com/brightdigit/SimulatorServices) library to interact with iOS simulators. This provides a clean API for:

- Finding active simulators
- Accessing simulator container paths
- Managing simulator file systems

The library handles the complexities of running `simctl` commands and parsing their output, making simulator authentication development significantly easier.

## Development Workflow

1. Developer authenticates through web interface
2. Server captures authentication data
3. Server writes data to simulator filesystem using SimulatorServices
4. `SimulatorLoginButton` watches for file changes
5. When file is detected, simulator app processes authentication data
6. User is authenticated in simulator environment

This approach maintains security while providing a smooth development experience.

## Security Considerations

- Simulator authentication only enabled in DEBUG builds
- Authentication data written to temporary locations
- File permissions properly managed
- Authentication tokens validated server-side