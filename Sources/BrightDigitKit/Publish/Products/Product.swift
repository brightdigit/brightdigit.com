import Foundation

struct Product {
  static let all: [Product] = [
    .heartwitch,
    Product(
      title: "Portrait",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo odio aenean sed adipiscing diam donec adipiscing tristique.",
      logo: "/media/images/products/sample/logo.jpeg",
      style: .portrait,
      screenshots: [
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg"
      ],
      pressCoverage: [
        .init(
          source: "9TO5Mac",
          quote: "It's Greatest App Ever! You must give them your Money!!!",
          url: "https://www.huxley.net/bnw/four.html",
          date: "2015-10-15"
        )
      ],
      platforms: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      technologies: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      productURL: "https://google.com",
      githubURL: "https://google.com"
    )
  ]

  internal init(title: String, description: String, isOpenSource: Bool = false, logo: String, style: Product.ScreenshotStyle = .default, screenshots: [String] = [], pressCoverage: [Product.PressCoverage] = [], platforms: [String], technologies: [String], productURL: String, githubURL: String? = nil) {
    self.description = description
    self.title = title
    self.isOpenSource = isOpenSource
    self.logo = URL(string: logo)!
    self.style = style
    self.screenshots = screenshots
    self.pressCoverage = pressCoverage
    self.platforms = platforms
    self.technologies = technologies
    self.productURL = URL(string: productURL)!
    self.githubURL = githubURL.map { URL(string: $0)! }
  }

  enum ScreenshotStyle: String, Codable, Equatable {
    case `default`, portrait, square
  }

  struct PressCoverage: Codable, Equatable, Hashable {
    internal init(source: String, quote: String, url: String, date: String) {
      self.source = source
      self.quote = quote
      self.url = URL(string: url)!
      self.date = PiHTMLFactory.dateFormatter.date(from: date)!
    }

    let source: String
    let quote: String
    let url: URL
    let date: Date
  }

  let title: String
  let description: String
  let isOpenSource: Bool
  let logo: URL
  let style: ScreenshotStyle
  let screenshots: [String]
  let pressCoverage: [PressCoverage]
  let platforms: [String]
  let technologies: [String]

  let productURL: URL
  let githubURL: URL?
}
