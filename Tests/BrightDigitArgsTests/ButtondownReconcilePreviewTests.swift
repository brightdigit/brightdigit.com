import ButtondownKit
import Configuration
import Foundation
import Spinetail
import Testing

@testable import BrightDigitArgs

/// Candidate selection, mode parsing, config, and preview export for
/// `buttondown reconcile` (#127).
internal struct ButtondownReconcilePreviewTests {
  private typealias Reconcile = Buttondown.ReconcileCommand

  @Test internal func preferredCandidateUsesFallbackOnlyForThinPrimary() {
    let thinHTML = Reconcile.BodyCandidate(
      body: "thin",
      words: 1,
      source: .selectedHTML
    )
    let recoveredPlainText = Reconcile.BodyCandidate(
      body: "recovered body",
      words: 150,
      source: .plainText
    )
    let sufficientHTML = Reconcile.BodyCandidate(
      body: "sufficient body",
      words: 120,
      source: .selectedHTML
    )

    #expect(
      Reconcile.preferredCandidate(
        primary: thinHTML,
        fallback: recoveredPlainText,
        minimumWords: 100
      ).source == .plainText
    )
    #expect(
      Reconcile.preferredCandidate(
        primary: sufficientHTML,
        fallback: recoveredPlainText,
        minimumWords: 100
      ).source == .selectedHTML
    )
  }

  @Test internal func reconcileRequiresExactlyOneMode() throws {
    #expect(try Reconcile.mode(execute: true, previewDirectory: nil) == .execute)
    #expect(
      try Reconcile.mode(execute: false, previewDirectory: " ./preview ")
        == .previewDirectory("./preview")
    )
    #expect(throws: CommandError.self) {
      _ = try Reconcile.mode(execute: false, previewDirectory: nil)
    }
    #expect(throws: CommandError.self) {
      _ = try Reconcile.mode(execute: true, previewDirectory: "preview")
    }
  }

  @Test internal func reconcileConfigRecognizesBareExecuteFlag() async throws {
    let reader = Configuration.ConfigReader(
      provider: CommandLineArgumentsProvider(arguments: [
        "brightdigitwg",
        "buttondown",
        "reconcile",
        "--mailchimp-api-key", "test-us1",
        "--mailchimp-list-id", "test-list",
        "--execute",
      ])
    )

    let config = try await Reconcile.Config(configuration: reader)

    #expect(config.execute)
    #expect(config.previewDirectory == nil)
  }

  @Test internal func previewDirectoryContainsBodiesAndIndex() throws {
    let directory = FileManager.default.temporaryDirectory
      .appendingPathComponent(UUID().uuidString, isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }

    let item = Reconcile.PlanItem(
      issueNo: 113,
      subject: "A subject | with a pipe",
      campaignID: "campaign-113",
      action: .update,
      existingEmailID: "email-113",
      existingStatus: .imported,
      previewText: "Preview",
      socialCardImageURL: "https://example.com/image.jpg",
      publishDate: ButtondownReconcileFixtures.day3
    )
    let resolved = Reconcile.ResolvedItem(
      item: item,
      body: "# Recovered\n\nFull converted body.",
      words: 4,
      source: .selectedHTML
    )

    try Reconcile.writePreview(
      resolved: .init(writable: [resolved], thin: []),
      missingIssueNos: [114],
      to: directory
    )

    let bodyURL = directory.appendingPathComponent("113-selected-html.md")
    let body = try String(contentsOf: bodyURL, encoding: .utf8)
    let index = try String(
      contentsOf: directory.appendingPathComponent("README.md"),
      encoding: .utf8
    )
    #expect(body == "# Recovered\n\nFull converted body.\n")
    #expect(index.contains("[selected-html](113-selected-html.md)"))
    #expect(index.contains("A subject \\| with a pipe"))
    #expect(index.contains("Absent from Buttondown (no converted file): #114"))
  }
}
