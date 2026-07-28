//
//  Buttondown.ReconcileCommand+Preview.swift
//  BrightDigit
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
import Spinetail

extension Buttondown.ReconcileCommand {
  /// Renders the "in Mailchimp, absent from Buttondown — skipped" advisory shown
  /// in both preview and execute reports.
  ///
  /// Empty when nothing is missing.
  internal static func missingLines(_ missingIssueNos: [Int]) -> [String] {
    guard !missingIssueNos.isEmpty else {
      return []
    }
    let list = missingIssueNos.map { "#\($0)" }.joined(separator: ", ")
    return [
      "",
      "Skipped (in Mailchimp, absent from Buttondown; never created): \(list)",
    ]
  }

  /// Logs a `buttondown reconcile:` diagnostic line to stderr.
  internal static func log(_ message: String) {
    FileHandle.standardError.write(
      Data("buttondown reconcile: \(message)\n".utf8)
    )
  }

  private static func metadataSummary(for item: PlanItem) -> String {
    let date = ISO8601DateFormatter().string(from: item.publishDate)
    let description = nonBlank(item.previewText) == nil ? "no" : "yes"
    let image = nonBlank(item.socialCardImageURL) == nil ? "no" : "yes"
    return "metadata: publish_date=\(date), description=\(description), image=\(image)"
  }

  /// A short, single-block preview of a cleaned body (first lines / characters).
  private static func previewSnippet(of body: String) -> String {
    let maxCharacters = 600
    let trimmed = body.prefix(maxCharacters)
    let suffix = body.count > maxCharacters ? "\n… (truncated)" : ""
    return trimmed + suffix
  }

  /// Deletes only files produced by an earlier preview run, leaving any
  /// unrelated contents of a caller-supplied directory untouched.
  private static func removePreviousPreview(in directory: URL) throws {
    let fileManager = FileManager.default
    let generatedName = #"^\d{3}-(?:selected-html|legacy-html|plain-text)\.md$"#
    for file in try fileManager.contentsOfDirectory(atPath: directory.path)
    where file.range(of: generatedName, options: .regularExpression) != nil {
      try fileManager.removeItem(at: directory.appendingPathComponent(file))
    }
  }

  /// Writes one resolved body to disk and returns its preview-index table row.
  private static func writeEntry(
    _ entry: (resolved: ResolvedItem, writable: Bool),
    to directory: URL,
    dateFormatter: ISO8601DateFormatter
  ) throws -> String {
    let resolved = entry.resolved
    let item = resolved.item
    let fileName = String(
      format: "%03d-%@.md",
      item.issueNo,
      resolved.source.rawValue
    )
    let body = resolved.body.hasSuffix("\n") ? resolved.body : resolved.body + "\n"
    try body.write(
      to: directory.appendingPathComponent(fileName),
      atomically: true,
      encoding: .utf8
    )
    let gate = entry.writable ? "UPDATE" : "SKIP"
    let description = nonBlank(item.previewText) == nil ? "no" : "yes"
    let image = nonBlank(item.socialCardImageURL) == nil ? "no" : "yes"
    let subject = item.subject
      .replacingOccurrences(of: "|", with: "\\|")
      .replacingOccurrences(of: "\n", with: " ")
    return
      "| #\(item.issueNo) | \(gate) | [\(resolved.source.rawValue)](\(fileName)) | "
      + "\(resolved.words) | \(dateFormatter.string(from: item.publishDate)) | "
      + "\(description) | \(image) | \(subject) |"
  }

  /// Writes reviewable Markdown bodies plus an index into a preview directory.
  internal static func writePreview(
    resolved: ResolvedUpdates,
    missingIssueNos: [Int],
    to directory: URL
  ) throws {
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    try removePreviousPreview(in: directory)

    let entries =
      resolved.writable.map { (resolved: $0, writable: true) }
      + resolved.thin.map { (resolved: $0, writable: false) }
    let sorted = entries.sorted { $0.resolved.item.issueNo < $1.resolved.item.issueNo }

    var index = [
      "# Buttondown reconcile preview",
      "",
      "No Buttondown writes were performed. Each linked file is the exact Markdown body",
      "that reconcile selected for that issue.",
      "",
      "| Issue | Gate | Source | Words | Publish date | Description | Image | Subject |",
      "| ---: | :---: | --- | ---: | --- | :---: | :---: | --- |",
    ]
    let dateFormatter = ISO8601DateFormatter()
    for entry in sorted {
      index.append(try writeEntry(entry, to: directory, dateFormatter: dateFormatter))
    }
    if !missingIssueNos.isEmpty {
      index.append("")
      index.append(
        "Absent from Buttondown (no converted file): "
          + missingIssueNos.map { "#\($0)" }.joined(separator: ", ")
      )
    }
    try (index.joined(separator: "\n") + "\n").write(
      to: directory.appendingPathComponent("README.md"),
      atomically: true,
      encoding: .utf8
    )
  }
}

extension Buttondown.ReconcileCommand {
  /// Renders the "cleaned body too thin — skipped" advisory for preview and
  /// execute modes.
  ///
  /// Empty when the gate rejected nothing.
  internal func thinLines(_ thin: [ResolvedItem]) -> [String] {
    guard !thin.isEmpty else {
      return []
    }
    var lines = [
      "",
      "Skipped (cleaned body under \(config.minBodyWords) words — not overwritten):",
    ]
    for resolved in thin {
      lines.append(
        "  SKIP  #\(resolved.item.issueNo)  [\(resolved.source.rawValue), "
          + "\(resolved.words) words]  \(resolved.item.subject)"
      )
    }
    return lines
  }

  /// Prints the reconciliation plan without performing Buttondown writes.
  ///
  /// Shows totals, a per-issue UPDATE line, and the issues skipped as absent or
  /// too thin to write. Every converted body is also exported to the preview
  /// directory by ``runPreview`` so the HTML→Markdown cleanup can be reviewed.
  internal func printPreviewReport(
    plan: Plan,
    campaignCount: Int,
    emailCount: Int,
    resolved: ResolvedUpdates
  ) {
    let writable = resolved.writable
    var lines: [String] = [
      "",
      "buttondown reconcile — PREVIEW (no Buttondown writes)",
      "====================================================",
      "Mailchimp sent campaigns: \(campaignCount)",
      "Buttondown emails:        \(emailCount)",
      "Numbered newsletters:     \(plan.items.count + plan.missingIssueNos.count)",
      "  UPDATE (clean body):    \(writable.count)",
      "  SKIP (thin body):       \(resolved.thin.count)",
      "  SKIP (absent, missing):  \(plan.missingIssueNos.count)",
    ]
    lines.append(contentsOf: thinLines(resolved.thin))
    lines.append(contentsOf: Self.missingLines(plan.missingIssueNos))
    lines.append("")
    lines.append("Plan (by issue number):")
    for resolved in writable {
      lines.append(
        "  UPDATE  #\(resolved.item.issueNo)  [\(resolved.source.rawValue), "
          + "\(resolved.words) words]  \(resolved.item.subject)"
      )
      lines.append("          \(Self.metadataSummary(for: resolved.item))")
    }
    print(lines.joined(separator: "\n"))

    let previewItems = Array(writable.prefix(2))
    guard !previewItems.isEmpty else {
      return
    }
    print("\nCleaned-body preview (\(previewItems.count) UPDATE issue(s)):")
    for resolved in previewItems {
      print("\n--- #\(resolved.item.issueNo): \(resolved.item.subject) ---")
      print(Self.previewSnippet(of: resolved.body))
    }
  }

  /// Resolves the plan, prints its report, and exports every converted body.
  internal func runPreview(
    plan: Plan,
    campaignCount: Int,
    emailCount: Int,
    mailchimp: MailchimpClient,
    directory: String
  ) async throws {
    let resolved = try await resolveUpdates(plan: plan, mailchimp: mailchimp)
    printPreviewReport(
      plan: plan,
      campaignCount: campaignCount,
      emailCount: emailCount,
      resolved: resolved
    )
    let outputURL = URL(
      fileURLWithPath: directory,
      relativeTo: FileManager.default.currentDirectoryURL
    ).standardizedFileURL
    try Self.writePreview(
      resolved: resolved,
      missingIssueNos: plan.missingIssueNos,
      to: outputURL
    )
    print("\nConverted Markdown written to \(outputURL.path)")
  }
}
