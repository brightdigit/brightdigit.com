import Foundation
import Plot

public struct Testimonial: Hashable, Comparable, Sendable {
  internal static let all: Set<Self> = .init([
    .derekDeJonghe, .daveCIO, .tomAssetHealth, .daveAM, .jody, .flickCMC, .hrAssetHealth,
    .davidSmith, .edCMC,
  ])

  internal let id: Int
  internal let fullName: String
  internal let title: String

  internal let fullQuote: String
  internal let briefQuote: String

  internal let url: URL?

  internal init(
    id: Int,
    fullName: String,
    title: String,
    fullQuote: String,
    briefQuote: String? = nil,
    url: URL? = nil
  ) {
    self.id = id
    self.fullName = fullName
    self.title = title
    self.fullQuote = fullQuote
    self.briefQuote = briefQuote ?? fullQuote
    self.url = url
  }

  public static func == (lhs: Testimonial, rhs: Testimonial) -> Bool {
    lhs.id == rhs.id
  }

  public static func < (lhs: Testimonial, rhs: Testimonial) -> Bool {
    lhs.id < rhs.id
  }
}

extension Testimonial {
  internal static func listItem(_ testimonial: Testimonial) -> Node<HTML.ListContext> {
    .li(
      .element(
        named: "figure",
        nodes: [
          .blockquote(
            .p(
              .text(testimonial.briefQuote)
            )
          ),
          .element(
            named: "figcaption",
            nodes: [
              .text("-"),
              .text(testimonial.fullName),
              .text(", "),
              .element(named: "cite", nodes: [.text(testimonial.title)]),
            ]
          ),
        ]
      )
    )
  }
}
