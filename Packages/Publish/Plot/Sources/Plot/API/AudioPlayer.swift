/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

/// Component used to render an `<audio>` element for inline audio playback.
public struct AudioPlayer: Component {
  /// Type used to define an audio player source, which points to an audio file.
  public struct Source {
    /// The URL of the audio file to use.
    public var url: URLRepresentable
    /// The audio file's format. See `HTMLAudioFormat` for more info.
    public var format: HTMLAudioFormat

    /// Create a new source.
    /// - Parameters:
    ///   - url: The URL of the audio file to use.
    ///   - format: The audio file's format. See `HTMLAudioFormat` for more info.
    public init(url: URLRepresentable, format: HTMLAudioFormat) {
      self.url = url
      self.format = format
    }

    /// Use an MP3 file at a given URL.
    /// - parameter url: The URL of the audio file to use.
    /// - Returns: The resulting audio source.
    public static func mp3(at url: URLRepresentable) -> Self {
      Source(url: url, format: .mp3)
    }

    /// Use a WAV file at a given URL.
    /// - parameter url: The URL of the audio file to use.
    /// - Returns: The resulting audio source.
    public static func wav(at url: URLRepresentable) -> Self {
      Source(url: url, format: .wav)
    }

    /// Use an OGG file at a given URL.
    /// - parameter url: The URL of the audio file to use.
    /// - Returns: The resulting audio source.
    public static func ogg(at url: URLRepresentable) -> Self {
      Source(url: url, format: .ogg)
    }
  }

  /// The sources that the player's audio files should be fetched from.
  public var sources: [Source]
  /// Whether the audio player should show its in-browser controls.
  public var showControls: Bool

  /// The content and behavior of this component.
  public var body: Component {
    Node.audio(
      .controls(showControls),
      .forEach(sources) { source in
        .source(.type(source.format), .src(source.url))
      }
    )
  }

  /// Initialize an audio player with a set of playback sources.
  /// - Parameters:
  ///   - sources: The sources that the player's audio files should
  ///     be fetched from.
  ///   - showControls: Whether the audio player should show its
  ///     in-browser controls.
  public init(sources: [Source], showControls: Bool) {
    self.sources = sources
    self.showControls = showControls
  }

  /// Initialize an audio player with a single playback source.
  /// - Parameters:
  ///   - source: The source that the player's audio file should
  ///     be fetched from.
  ///   - showControls: Whether the audio player should show its
  ///     in-browser controls.
  public init(source: Source, showControls: Bool) {
    self.init(sources: [source], showControls: showControls)
  }
}
