import Foundation

public protocol AudioPodcastItem {
  var podcastID : String { get }
  var episodeNo : Int { get }
  var slug : String { get }
  var title : String { get }
  var date : Date { get }
  var summary : String { get }
  var content : String { get }
  var duration : TimeInterval { get }
  var imageURL : URL { get }
  var audioURL : URL { get }
}
