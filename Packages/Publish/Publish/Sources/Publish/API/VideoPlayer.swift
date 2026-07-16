/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

/// Component that can be used to render an inline video player, using either
/// the `<video>` element (for hosted videos), or by embedding either a YouTube
/// or Vimeo player using an `<iframe>`.
public struct VideoPlayer: Component {
  /// The video to create a player for.
  public var video: Video
  /// Whether playback controls should be shown to the user. Note that this
  /// property is ignored when rendering a video hosted by a service like YouTube.
  public var showControls: Bool

  /// The rendered body of the component.
  public var body: Component {
    switch video {
    case .hosted(let url, let format):
      return Node.video(
        .controls(showControls),
        .source(.type(format), .src(url))
      )
    case .youTube(let id):
      let url = "https://www.youtube-nocookie.com/embed/" + id
      return iframeVideoPlayer(for: url)
    case .vimeo(let id):
      let url = "https://player.vimeo.com/video/" + id
      return iframeVideoPlayer(for: url)
    }
  }

  /// Create an inline player for a `Video` model.
  /// - Parameters:
  ///   - video: The video to create a player for.
  ///   - showControls: Whether playback controls should be shown to the user.
  ///       Note that this parameter is only relevant for hosted videos.
  public init(video: Video, showControls: Bool = true) {
    self.video = video
    self.showControls = showControls
  }

  private func iframeVideoPlayer(for url: URLRepresentable) -> Component {
    IFrame(
      url: url,
      addBorder: false,
      allowFullScreen: true,
      enabledFeatureNames: [
        "accelerometer",
        "encrypted-media",
        "gyroscope",
        "picture-in-picture",
      ]
    )
  }
}
