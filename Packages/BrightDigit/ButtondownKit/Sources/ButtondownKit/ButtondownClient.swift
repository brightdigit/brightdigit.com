//
//  ButtondownClient.swift
//  ButtondownKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import OpenAPIRuntime

// URLSession transport is unavailable on WASI; the apiKey-based initializers that
// build a `URLSessionTransport` are gated behind #if !os(WASI) below. WASI callers
// construct a `Client` with a wasm-compatible transport and use `init(underlying:)`.
#if !os(WASI)
  import OpenAPIURLSession
#endif

/// A high-level async client for the subset of the Buttondown API used for
/// newsletter publishing.
///
/// ``ButtondownClient`` wraps the swift-openapi-generator ``Client`` with an
/// ``AuthenticationMiddleware`` and exposes a small, ergonomic surface via the
/// capability protocols it conforms to: ``EmailListing`` (list/page emails),
/// ``EmailDrafting`` (create/send drafts), and ``EmailRetrieving`` (read one
/// email). Those capabilities implement their methods against ``underlying`` in
/// extensions constrained on ``UnderlyingClientProtocol``, so this type is only
/// storage plus initializers. All results are Swift-native domain types
/// (``Email`` et al.), never the generated `Components.Schemas.*`.
///
/// The underlying transport defaults to `URLSessionTransport`, which works on
/// both Apple platforms and Linux. No subscriber/audience data is stored in the
/// repository; the API key is supplied via the `BUTTONDOWN_API_KEY` environment
/// variable.
public struct ButtondownClient: Sendable, UnderlyingClientProtocol,
  EmailListing, EmailDrafting, EmailRetrieving
{
  /// Errors surfaced by ``ButtondownClient``.
  public enum ClientError: Error, Equatable {
    /// `BUTTONDOWN_API_KEY` was not set in the environment.
    case missingAPIKey
    /// The server returned a response the client could not interpret as
    /// success (an undocumented status, or a documented error response).
    case unexpectedResponse
  }

  /// The generated, transport-backed API client.
  public let underlying: Client

  /// Creates a client from a pre-built generated ``Client``.
  ///
  /// Primarily used by tests to inject a mock transport. Production callers
  /// should prefer ``init(apiKey:)`` or ``fromEnvironment()``.
  /// - Parameter underlying: The generated client to wrap.
  public init(underlying: Client) {
    self.underlying = underlying
  }

  /// The client configuration used by the URLSession-backed initializers.
  ///
  /// Installs ``LenientISO8601DateTranscoder`` so the mixed fractional/whole
  /// second timestamps the Buttondown API returns both decode successfully.
  public static var defaultConfiguration: Configuration {
    Configuration(dateTranscoder: LenientISO8601DateTranscoder())
  }

  // URLSession-backed conveniences. Unavailable on WASI (no URLSessionTransport);
  // build a `Client` with a wasm-compatible transport and use `init(underlying:)`.
  #if !os(WASI)
    /// Creates a client that talks to the live Buttondown API with the given key.
    /// - Parameter apiKey: The Buttondown API key.
    /// - Throws: An error if the server URL cannot be constructed.
    public init(apiKey: String) throws {
      let client = Client(
        serverURL: try Servers.Server1.url(),
        configuration: Self.defaultConfiguration,
        transport: URLSessionTransport(),
        middlewares: [AuthenticationMiddleware(apiKey: apiKey)]
      )
      self.init(underlying: client)
    }

    /// Creates a client using the `BUTTONDOWN_API_KEY` environment variable.
    /// - Throws: ``ClientError/missingAPIKey`` if the variable is unset/empty.
    public static func fromEnvironment() throws -> ButtondownClient {
      guard
        let apiKey = ProcessInfo.processInfo.environment["BUTTONDOWN_API_KEY"],
        !apiKey.isEmpty
      else {
        throw ClientError.missingAPIKey
      }
      return try ButtondownClient(apiKey: apiKey)
    }
  #endif
}
