import Foundation
import HTTPTypes
import OpenAPIRuntime

/// A `ClientTransport` that returns pre-canned JSON bodies keyed by URL path.
///
/// Records every request it receives (path and `Authorization` header) so tests
/// can assert on routing and authentication.
final class MockTransport: ClientTransport, @unchecked Sendable {
  /// JSON response bodies keyed by URL path; consumed in order per path.
  private var responses: [String: [String]]
  /// Status code returned for every request.
  private let status: Int
  /// `Content-Type` returned for every response body.
  private let contentType: String
  /// Every request URL path the transport observed, in order.
  private(set) var requestedPaths: [String] = []
  /// Every `Authorization` header value observed, in order.
  private(set) var authorizationHeaders: [String] = []

  init(
    responses: [String: [String]],
    status: Int = 200,
    contentType: String = "application/json"
  ) {
    self.responses = responses
    self.status = status
    self.contentType = contentType
  }

  func send(
    _ request: HTTPRequest,
    body _: HTTPBody?,
    baseURL _: URL,
    operationID _: String
  ) async throws -> (HTTPResponse, HTTPBody?) {
    let path = request.path ?? ""
    requestedPaths.append(path)
    if let auth = request.headerFields[.authorization] {
      authorizationHeaders.append(auth)
    }
    let key = String(path.split(separator: "?").first ?? "")

    guard var queue = responses[key], !queue.isEmpty else {
      return (HTTPResponse(status: .init(code: 404)), nil)
    }
    let json = queue.removeFirst()
    responses[key] = queue

    let response = HTTPResponse(
      status: .init(code: status),
      headerFields: [.contentType: contentType]
    )
    return (response, HTTPBody(json))
  }
}
