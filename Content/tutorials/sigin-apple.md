---
title: Setting Up Sign in with Apple with Vapor and SwiftUI
date: 2025-05-09 00:00
description: A comprehensive guide to implementing Sign in with Apple in your Vapor server and SwiftUI client applications
featuredImage: /media/articles/scale-ios-app/overgrown-green-staircase-in-the-forest.jpg
---

Sign in with Apple provides a secure and privacy-focused authentication method for your apps. This guide will show you how to:
* Set up Sign in with Apple with Vapor
* Implement Sign in with Apple in a SwiftUI app
* Handle authentication tokens securely

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
Our main authentication view conditionally renders the Sign in with Apple button:

```swift
struct AuthenticationView: View {
    @StateObject private var object: AuthenticationObject
    private var service: AuthenticationService
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
            .frame(height: 40, alignment: .center)
        }
    }
}
```

## Security Best Practices

When implementing Sign in with Apple, follow these security best practices:

1. Always verify tokens on the server side
2. Use proper JWT validation including audience and issuer checks
3. Store tokens securely using Keychain
4. Implement proper error handling and user feedback
5. Follow Apple's guidelines for button styling and placement

## Next Steps

Now that you have Sign in with Apple working in your app, you might want to:

* Add support for other authentication methods
* Implement token refresh logic
* Add proper error handling and user feedback
* Set up testing infrastructure

For testing Sign in with Apple in the simulator environment, especially for watchOS, check out our follow-up article on [Setting up Sign in with Apple for watchOS Simulator Testing](/tutorials/signin-apple-simulator).