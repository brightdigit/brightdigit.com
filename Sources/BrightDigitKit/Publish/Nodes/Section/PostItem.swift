import Foundation
import Plot
import Publish

protocol SocialShare {
  func shareURL(for item: PostItem) -> URL
  var actionText: String { get }
  var nameText: String { get }
  var flaticonName: String { get }
}

protocol SocialQueryItemsShare: SocialShare {
  func queryItems(for item: PostItem) -> [URLQueryItem]
  static var baseURLComponents: URLComponents { get }
}

extension SocialQueryItemsShare {
  func shareURL(for item: PostItem) -> URL {
    var urlComponents = Self.baseURLComponents
    urlComponents.queryItems = queryItems(for: item)
    return urlComponents.url!
  }
}

struct TwitterSocialShare: SocialQueryItemsShare {
  let flaticonName: String = "twitter"

  static let baseURLComponents = URLComponents(string: "https://twitter.com/intent/tweet")!
  func queryItems(for item: PostItem) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "text", value: item.title))
    queryItems.append(URLQueryItem(name: "url", value: item.absoluteURL.absoluteString))
    queryItems.append(URLQueryItem(name: "via", value: item.source.sectionID == .tutorials ? "@leogdion" : "@brightdigit"))
    return queryItems
  }

  let actionText: String = "Share On"
  let nameText: String = "Twitter"
}

struct LinkedInSocialShare: SocialQueryItemsShare {
  let flaticonName: String = "linkedin"
  static let baseURLComponents = URLComponents(string: "http://www.linkedin.com/shareArticle")!
  func queryItems(for item: PostItem) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "title", value: item.title))
    queryItems.append(URLQueryItem(name: "summary", value: item.description))
    queryItems.append(URLQueryItem(name: "source", value: "brightdigit.com"))
    queryItems.append(URLQueryItem(name: "url", value: item.absoluteURL.absoluteString))
    return queryItems
  }

  let actionText: String = "Share On"
  let nameText: String = "LinkedIn"
}

struct BuffferSocialShare: SocialQueryItemsShare {
  let flaticonName: String = "buffer"
  static let baseURLComponents = URLComponents(string: "https://publish.buffer.com/compose")!
  func queryItems(for item: PostItem) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "text", value: item.title))
    queryItems.append(URLQueryItem(name: "url", value: item.absoluteURL.absoluteString))
    return queryItems
  }

  let actionText: String = "Share With"
  let nameText: String = "Buffer"
}

struct EmailSocialShare: SocialQueryItemsShare {
  let flaticonName: String = "newsletter"
  static let baseURLComponents = URLComponents(string: "mailto:")!
  func queryItems(for item: PostItem) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "subject", value: item.title))
    queryItems.append(URLQueryItem(name: "body", value: "\(item.description)\n\n\(item.absoluteURL)"))
    return queryItems
  }

  let actionText: String = "Share With"
  let nameText: String = "Email"
}

struct PostItem: SectionItem {
  let slug: String
  let description: String
  let featuredImageURL: URL
  let title: String
  let publishedDate: Date
  let source: Item<BrightDigitSite>
  let site: BrightDigitSite
  let subscriptionCTA: String?

  let isFeatured: Bool

  var featuredItemContent: [Node<HTML.BodyContext>] {
    [
      .header(
        .img(.src(featuredImageURL))
      ),
      .main(
        .header(
          .a(
            .h2(.text(title)),

            .href(source.path)
          )
        ),
        .main(
          .text(description)
        ),
        .footer(
          " published on ",
          .span(
            .class("published-date"),
            .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
          )
        )
      )
    ]
  }

  var sectionItemContent: [Node<HTML.BodyContext>] {
    [
      .id("post-\(slug)"),
      .header(
        .img(.src(featuredImageURL)),
        .a(
          .href(source.path),
          .h2(.text(title))
        )
      ),
      .main(
        .text(description)
      ),
      .footer(
        .a(
          .text(PiHTMLFactory.itemFormatter.string(from: publishedDate))
        )
      )
    ]
  }

  var pageTitle: String {
    title
  }

  var pageBodyID: String? {
    nil
  }

  var linkedInShareURL: URL {
    var urlComponents = Self.linkedInShareBaseURLComponents
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "title", value: ""))
    queryItems.append(URLQueryItem(name: "summary", value: ""))
    queryItems.append(URLQueryItem(name: "source", value: ""))
    queryItems.append(URLQueryItem(name: "url", value: ""))
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }

  var bufferShareURL: URL {
    var urlComponents = Self.bufferBaseURLComponents
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "text", value: ""))
    queryItems.append(URLQueryItem(name: "url", value: ""))
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }

  var absoluteURL: URL {
    source.absoluteURL(forSite: site)
  }

  var twitterIntentURL: URL {
    var urlComponents = Self.bufferBaseURLComponents
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "text", value: ""))
    queryItems.append(URLQueryItem(name: "url", value: ""))
    queryItems.append(URLQueryItem(name: "via", value: ""))
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }

  var mailToURL: URL {
    var urlComponents = Self.bufferBaseURLComponents
    var queryItems = [URLQueryItem]()
    queryItems.append(URLQueryItem(name: "subject", value: ""))
    queryItems.append(URLQueryItem(name: "body", value: ""))
    urlComponents.queryItems = queryItems
    return urlComponents.url!
  }

  static let twitterIntentBaseURLComponents = URLComponents(string: "https://twitter.com/intent/tweet")!
  static let linkedInShareBaseURLComponents = URLComponents(string: "http://www.linkedin.com/shareArticle")!
  static let mailToBaseURLComponents = URLComponents(string: "mailto:")!
  static let bufferBaseURLComponents = URLComponents(string: "https://publish.buffer.com/compose")!

  func shareListItem(for share: SocialShare) -> Node<HTML.ListContext> {
    .li(
      .a(
        .href(share.shareURL(for: self)),
        .target(.blank),
        .span(
          .class("action"),
          .text(share.actionText)
        ),
        .span(
          .class("name"),
          .text(share.nameText)
        ),
        .i(.class("flaticon-\(share.flaticonName)"))
      )
    )
    //          <li>
    //            <a href="https://publish.buffer.com/compose?url=https://www.google.com/search?client%3Dsafari%26rls%3Den%26q%3Dbuffer+social+share%26ie%3DUTF-8%26oe%3DUTF-8&amp;text=buffer%20social%20share%20-%20Google%20Search" class="author">
    //              <span class="action">Share on</span>
    //              <span class="name">Twitter</span>
    //              <i class="flaticon-twitter"></i>
    //            </a>
    //          </li>
  }

  static let socialShares: [SocialShare] = [
    TwitterSocialShare(),
    LinkedInSocialShare(),
    BuffferSocialShare(),
    EmailSocialShare()
  ]
  var pageHeader: Node<HTML.BodyContext> {
    .header(
      .header(
        .img(.src(featuredImageURL)),
        .h1(.text(title))
      ),
      .footer(
        .ol(
          .forEach(Self.socialShares, shareListItem(for:))
        ),
        .div(
          .class("readtime"),
          .text("\(source.readingTime.minutes) mins")
        )
      )
    )
    //      <header>
    //              <header>
    //                <img src="/media/wp-images/learningswift/2019/09/Screen-Shot-2019-09-23-at-5.30.47-PM.png">
    //      -        <h1>Asynchronous Multi-Threaded Parallel World of Swift</h1>
    //              </header>
    //              <footer>
    //              <ol>
    //
    //          <li>
    //            <a href="https://publish.buffer.com/compose?url=https://www.google.com/search?client%3Dsafari%26rls%3Den%26q%3Dbuffer+social+share%26ie%3DUTF-8%26oe%3DUTF-8&amp;text=buffer%20social%20share%20-%20Google%20Search" class="author">
    //              <span class="action">Share on</span>
    //              <span class="name">Twitter</span>
    //              <i class="flaticon-twitter"></i>
    //            </a>
    //          </li>
    //          <li>
    //            <a href="https://publish.buffer.com/compose?url=https://www.google.com/search?client%3Dsafari%26rls%3Den%26q%3Dbuffer+social+share%26ie%3DUTF-8%26oe%3DUTF-8&amp;text=buffer%20social%20share%20-%20Google%20Search" class="author">
    //              <span class="action">Share on</span>
    //              <span class="name">LinkedIn</span>
    //              <i class="flaticon-linkedin"></i>
    //            </a>
    //          </li>
    //          <li>
    //            <a href="https://publish.buffer.com/compose?url=https://www.google.com/search?client%3Dsafari%26rls%3Den%26q%3Dbuffer+social+share%26ie%3DUTF-8%26oe%3DUTF-8&amp;text=buffer%20social%20share%20-%20Google%20Search" class="author">
    //              <span class="action">Share with</span>
    //              <span class="name">Email</span>
    //              <i class="flaticon-newsletter"></i>
    //            </a>
    //          </li>
    //          <li>
    //            <a href="https://publish.buffer.com/compose?url=https://www.google.com/search?client%3Dsafari%26rls%3Den%26q%3Dbuffer+social+share%26ie%3DUTF-8%26oe%3DUTF-8&amp;text=buffer%20social%20share%20-%20Google%20Search" class="author">
    //              <span class="action">Share with</span>
    //              <span class="name">Buffer</span>
    //              <i class="flaticon-buffer"></i>
    //            </a>
    //          </li>
    //              </ol>
    //              <div class="readtime">4 mins</div>
    //            </footer>
    //      </header>
  }

  var pageFooter: Node<HTML.BodyContext> {
    .footer(
      .ol(
        .forEach(Self.socialShares, shareListItem(for:))
      ),
      .main(
        .main(
          .unwrap(subscriptionCTA) {
            .h2(.text($0))
          },
          .h3("The BrightDigit newsletter gives you regular helpful tips and advice right to your inbox!"),
          .p(
            .markdown(
              "A couple of times a month, I publish a [newsletter](/newsletters), with news, updates, and other content related to Apple and iOS. I try to help people better understand how to succeed with iOS apps, and keep you informed about what’s coming up on the horizon for the industry."
            )
          )
        ),

        .form(
          .div(
            .div(
              .input(.type(.text), .placeholder("leo@brightdigit.com")),
              .label("Email")
            )
          ),
          .div(
            .div(
              .button("Sign me up!")
            )
          )
        )
      )
    )
    //        <main>
    //        <main>
    //      <h2>Want to avoid more mistakes in iOS development?</h2><h2>
    //      </h2><h3>The BrightDigit newsletter gives you regular helpful tips and advice right to your inbox!</h3>
    //      <p>A couple of times a month, I publish a <a href="/newsletters">newsletter</a>, with news, updates, and other content related to Apple and iOS. I try to help people better understand how to succeed with iOS apps, and keep you informed about what’s coming up on the horizon for the industry.</p>
    //      </main>
    //      <form>
    //        <div>
    //          <div>
    //            <input type="text" placeholder="leo@brightdigit.com">
    //            <label>Email</label>
    //          </div>
    //        </div>
    //        <div>
    //          <div>
    //            <button>Sign me up!</button>
    //          </div>
    //        </div>
    //      </form>
    //
    //      </main>
    //      </footer>
  }

  var pageMainContent: [Node<HTML.BodyContext>] {
    [
      pageHeader,
      .main(.contentBody(source.body)),
      pageFooter
    ]
  }

  init(item: Item<BrightDigitSite>, site: BrightDigitSite) throws {
    source = item
    self.site = site
    let featuredImageURL = item.featuredImageURL
    let isFeatured = item.metadata.featured ?? false

    subscriptionCTA = item.metadata.subscriptionCTA
    slug = item.path.string
    title = item.title
    description = item.description
    self.featuredImageURL = featuredImageURL
    publishedDate = item.metadata.date
    self.isFeatured = isFeatured
  }
}
