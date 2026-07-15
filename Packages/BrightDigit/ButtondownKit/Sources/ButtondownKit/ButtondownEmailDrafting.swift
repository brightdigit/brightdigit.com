//
//  ButtondownEmailDrafting.swift
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

/// The capability to create draft emails and send them.
public protocol ButtondownEmailDrafting: ButtondownClientProtocol {
  /// Creates a draft email from a Markdown body.
  /// - Parameters:
  ///   - subject: The email subject line.
  ///   - body: The Markdown body of the email.
  /// - Returns: The created ``ButtondownEmail``.
  /// - Throws: An error if the request fails or the response is unexpected.
  func createDraft(subject: String, body: String) async throws -> ButtondownEmail

  /// Sends a previously-created draft to all subscribers.
  /// - Parameter id: The id of the draft email to send.
  /// - Throws: An error if the request fails or the response is unexpected.
  func sendDraft(id: String) async throws
}

extension ButtondownEmailDrafting {
  /// Creates a draft email (newsletter issue) from a Markdown body.
  ///
  /// Maps to `POST /emails`. Buttondown is Markdown-native, so `body` is sent
  /// as-is with no HTML conversion.
  /// - Parameters:
  ///   - subject: The email subject line.
  ///   - body: The Markdown body of the email.
  /// - Returns: The created ``ButtondownEmail``.
  /// - Throws: ``ButtondownClient/ClientError/unexpectedResponse`` on a non-201
  ///   response, or a transport/decoding error.
  public func createDraft(
    subject: String,
    body: String
  ) async throws -> ButtondownEmail {
    let input = Components.Schemas.EmailInput(
      body: body,
      status: .init(value1: .draft),
      subject: subject
    )
    let output = try await underlying.create_email(body: .json(input))
    switch output {
    case .created(let created):
      return try ButtondownEmail(from: created.body.json)
    default:
      throw ButtondownClient.ClientError.unexpectedResponse
    }
  }

  /// Sends a previously-created draft to all subscribers.
  ///
  /// Maps to `POST /emails/{id}/send-draft`.
  /// - Parameter id: The id of the draft email to send.
  /// - Throws: ``ButtondownClient/ClientError/unexpectedResponse`` on a non-200
  ///   response, or a transport error.
  public func sendDraft(id: String) async throws {
    let output = try await underlying.send_draft(
      path: .init(id: id),
      body: .json(.init())
    )
    switch output {
    case .ok:
      return
    default:
      throw ButtondownClient.ClientError.unexpectedResponse
    }
  }
}
