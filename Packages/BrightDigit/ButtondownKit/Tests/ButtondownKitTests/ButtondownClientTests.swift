//
//  ButtondownClientTests.swift
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
import HTTPTypes
import OpenAPIRuntime
import XCTest

@testable import ButtondownKit

internal final class ButtondownClientTests: XCTestCase {
  private static let apiKey = "FAKE_KEY"
  private static let emailID = "00000000-0000-0000-0000-000000000001"

  /// Loads a JSON fixture from the test bundle's copied `Fixtures` directory.
  private func fixture(_ name: String) throws -> String {
    let url = try XCTUnwrap(
      Bundle.module.url(
        forResource: name,
        withExtension: "json",
        subdirectory: "Fixtures"
      ),
      "missing fixture \(name).json"
    )
    return try String(contentsOf: url, encoding: .utf8)
  }

  /// Builds a `ButtondownClient` over the supplied mock transport, with the
  /// real authentication middleware in place so its behaviour is exercised.
  private func makeClient(_ transport: MockTransport) throws -> ButtondownClient {
    let generated = Client(
      serverURL: try Servers.Server1.url(),
      transport: transport,
      middlewares: [AuthenticationMiddleware(apiKey: Self.apiKey)]
    )
    return ButtondownClient(underlying: generated)
  }

  /// `createDraft` POSTs the Markdown body and decodes the 201 `Email` back —
  /// the create-draft round trip.
  internal func testCreateDraftRoundTrip() async throws {
    let transport = MockTransport(responses: [
      "POST /emails": [.init(status: 201, json: try fixture("email-created"))]
    ])
    let client = try makeClient(transport)

    let email = try await client.createDraft(
      subject: "Hello from ButtondownKit",
      body: "# Heading\n\nThis is a **Markdown** newsletter body."
    )

    XCTAssertEqual(email.id, Self.emailID)
    XCTAssertEqual(email.subject, "Hello from ButtondownKit")
    XCTAssertEqual(email.status, .draft)
    XCTAssertEqual(email.source, .api)

    // The request carried the Markdown body unchanged (no HTML conversion).
    let recorded = await transport.recorded
    let request = try XCTUnwrap(recorded.first)
    XCTAssertEqual(request.method, "POST")
    XCTAssertEqual(request.path, "/emails")
    let body = try XCTUnwrap(request.body)
    XCTAssertTrue(body.contains("**Markdown**"))
    XCTAssertTrue(body.contains("draft"), "status should serialize as draft")
  }

  /// The authentication middleware attaches `Authorization: Token <key>`.
  internal func testAuthorizationHeaderIsAttached() async throws {
    let transport = MockTransport(responses: [
      "POST /emails": [.init(status: 201, json: try fixture("email-created"))]
    ])
    let client = try makeClient(transport)

    _ = try await client.createDraft(subject: "s", body: "b")

    let recorded = await transport.recorded
    let request = try XCTUnwrap(recorded.first)
    XCTAssertEqual(
      request.headerFields[.authorization],
      "Token \(Self.apiKey)"
    )
  }

  /// `sendDraft` hits `POST /emails/{id}/send-draft` and treats 200 as success.
  internal func testSendDraft() async throws {
    let transport = MockTransport(responses: [
      "POST /emails/\(Self.emailID)/send-draft": [.init(status: 200, json: "{}")]
    ])
    let client = try makeClient(transport)

    try await client.sendDraft(id: Self.emailID)

    let recorded = await transport.recorded
    let request = try XCTUnwrap(recorded.first)
    XCTAssertEqual(request.method, "POST")
    XCTAssertEqual(request.path, "/emails/\(Self.emailID)/send-draft")
  }

  /// `email(id:)` reads back a single email via `GET /emails/{id}`.
  internal func testRetrieveEmail() async throws {
    let transport = MockTransport(responses: [
      "GET /emails/\(Self.emailID)": [.init(status: 200, json: try fixture("email-created"))]
    ])
    let client = try makeClient(transport)

    let email = try await client.email(id: Self.emailID)

    XCTAssertEqual(email.id, Self.emailID)
    let recorded = await transport.recorded
    XCTAssertEqual(recorded.first?.method, "GET")
  }

  /// A documented error status (403) surfaces as `unexpectedResponse`.
  internal func testForbiddenSurfacesAsError() async throws {
    let transport = MockTransport(responses: [
      "POST /emails": [
        .init(status: 403, json: #"{"detail":"nope","code":"forbidden"}"#)
      ]
    ])
    let client = try makeClient(transport)

    do {
      _ = try await client.createDraft(subject: "s", body: "b")
      XCTFail("expected ClientError.unexpectedResponse")
    } catch let error as ButtondownClient.ClientError {
      XCTAssertEqual(error, .unexpectedResponse)
    }
  }

  /// `fromEnvironment()` throws when `BUTTONDOWN_API_KEY` is unset.
  internal func testFromEnvironmentMissingKeyThrows() throws {
    if ProcessInfo.processInfo.environment["BUTTONDOWN_API_KEY"] != nil {
      throw XCTSkip("BUTTONDOWN_API_KEY is set in this environment")
    }
    XCTAssertThrowsError(try ButtondownClient.fromEnvironment()) { error in
      XCTAssertEqual(
        error as? ButtondownClient.ClientError,
        .missingAPIKey
      )
    }
  }
}
