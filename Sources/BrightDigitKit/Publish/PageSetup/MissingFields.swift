import Foundation

enum MissingFields {
  enum NewsletterField: String, MissingField {
    case featuredImageURL
    case issueNo
    case archiveURL
    case publishedDate

    static let typeName: String = "Newsletter"
    var fieldName: String {
      rawValue
    }
  }

  enum PodcastField: String, MissingField {
    case featuredImageURL
    case episodeNo
    case audioDuration
    case publishedDate
    static let typeName: String = "PodcastEpisode"
    var fieldName: String {
      rawValue
    }
  }

  enum ArticleField: String, MissingField {
    case featuredImageURL
    case publishedDate
    static let typeName: String = "Article"
    var fieldName: String {
      rawValue
    }
  }

  enum TutorialField: String, MissingField {
    case featuredImageURL
    case publishedDate
    static let typeName: String = "Tutorial"
    var fieldName: String {
      rawValue
    }
  }
  
  enum ProductField: String, MissingField {
    case logo
    case productURL
    static let typeName: String = "Product"
    var fieldName: String {
      rawValue
    }
  }
}
