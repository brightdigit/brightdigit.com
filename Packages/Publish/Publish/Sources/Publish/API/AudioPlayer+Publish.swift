/**
*  Publish
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import Plot

extension AudioPlayer {
  /// Create an inline player for an `Audio` model.
  /// - Parameters:
  ///   - audio: The audio to create a player for.
  ///   - showControls: Whether playback controls should be shown to the user.
  public init(audio: Audio, showControls: Bool = true) {
    self.init(
      source: Source(url: audio.url, format: audio.format),
      showControls: showControls
    )
  }
}
