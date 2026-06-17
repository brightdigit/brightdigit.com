import Foundation
import OpenAPIRuntime
import XCTest

@testable import SpinetailOpenAPI

final class MailchimpClientTests: XCTestCase {
  private static let listID = "list123"
  private static let campaignsPath = "/campaigns"
  private static let contentPath = "/campaigns/camp1/content"
  private static let apiKey = "abc123-us21"

  /// Builds a `MailchimpClient` whose generated client uses the supplied mock,
  /// with the Basic-auth middleware attached (matching production wiring).
  private func makeClient(_ transport: MockTransport) throws -> MailchimpClient {
    let generated = try Client(
      serverURL: MailchimpClient.serverURL(forAPIKey: Self.apiKey),
      transport: transport,
      middlewares: [AuthenticationMiddleware(apiKey: Self.apiKey)]
    )
    return MailchimpClient(client: generated)
  }

  /// The base URL host is derived from the API key's datacenter suffix.
  func testServerURLDerivedFromAPIKey() throws {
    let url = try MailchimpClient.serverURL(forAPIKey: "key-us21")
    XCTAssertEqual(url.absoluteString, "https://us21.api.mailchimp.com/3.0")
  }

  /// An API key with no datacenter suffix is rejected.
  func testServerURLRejectsKeyWithoutDatacenter() {
    XCTAssertThrowsError(
      try MailchimpClient.serverURL(forAPIKey: "nodatacenter")
    ) { error in
      XCTAssertEqual(
        error as? MailchimpClient.ClientError, .invalidAPIKey
      )
    }
  }

  /// `sentCampaigns(forListID:)` maps the OK response into flat models and
  /// attaches the Basic-auth header.
  func testListCampaignsMapsFieldsAndAuthenticates() async throws {
    let transport = MockTransport(
      responses: [Self.campaignsPath: [Fixtures.campaigns]]
    )
    let client = try makeClient(transport)

    let campaigns = try await client.sentCampaigns(forListID: Self.listID)

    XCTAssertEqual(campaigns.map(\.id), ["camp1", "camp2"])
    XCTAssertEqual(
      campaigns.first?.subjectLine, "BrightDigit Newsletter #1"
    )
    XCTAssertEqual(campaigns.first?.title, "Issue One")
    XCTAssertEqual(campaigns.first?.previewText, "first preview")
    XCTAssertEqual(
      campaigns.first?.segmentText, "brightdigit-business"
    )
    XCTAssertEqual(
      campaigns.first?.socialCardImageURL, "https://img/1.jpg"
    )
    XCTAssertEqual(
      campaigns.first?.longArchiveURL, "https://archive/1"
    )

    let expectedAuth =
      "Basic " + Data("anystring:\(Self.apiKey)".utf8).base64EncodedString()
    XCTAssertEqual(transport.authorizationHeaders.first, expectedAuth)
  }

  /// `archiveHTML(forCampaignID:)` returns the campaign's `archive_html`.
  func testArchiveHTMLReturnsArchiveHTML() async throws {
    let transport = MockTransport(
      responses: [Self.contentPath: [Fixtures.campaignContent]]
    )
    let client = try makeClient(transport)

    let html = try await client.archiveHTML(forCampaignID: "camp1")

    XCTAssertEqual(html, "<html><body>Hello</body></html>")
  }

  /// A content response missing `archive_html` surfaces `missingHTML`.
  func testArchiveHTMLThrowsWhenMissing() async throws {
    let transport = MockTransport(
      responses: [Self.contentPath: [Fixtures.campaignContentNoHTML]]
    )
    let client = try makeClient(transport)

    do {
      _ = try await client.archiveHTML(forCampaignID: "camp1")
      XCTFail("expected ClientError.missingHTML")
    } catch let error as MailchimpClient.ClientError {
      XCTAssertEqual(error, .missingHTML(campaignID: "camp1"))
    }
  }

  /// A non-200 (problem+json) response surfaces as
  /// `ClientError.invalidResponse`.
  func testNon200ResponseThrows() async throws {
    let transport = MockTransport(
      responses: [Self.campaignsPath: [Fixtures.problem]],
      status: 500,
      contentType: "application/problem+json"
    )
    let client = try makeClient(transport)

    do {
      _ = try await client.sentCampaigns(forListID: Self.listID)
      XCTFail("expected ClientError.invalidResponse")
    } catch let error as MailchimpClient.ClientError {
      XCTAssertEqual(error, .invalidResponse)
    }
  }
}
