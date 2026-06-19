import Testing

@testable import BrightDigitArgs

internal struct YouTubeIDExtractionTests {
  @Test internal func extractsWatchIDFromShowNotes() {
    let html = """
      <p>Watch this episode:
      <a href="https://www.youtube.com/watch?v=1U3pXddDYo0" \
      title="Click here to watch a video of this episode.">Watch</a></p>
      """
    #expect(Import.PodcastCommand.youtubeIDs(in: html) == ["1U3pXddDYo0"])
  }

  @Test internal func extractsShortAndEmbedForms() {
    #expect(
      Import.PodcastCommand.youtubeIDs(in: "see https://youtu.be/abcDEF12345 now")
        == ["abcDEF12345"]
    )
    #expect(
      Import.PodcastCommand.youtubeIDs(
        in: #"<iframe src="https://www.youtube.com/embed/ABCdef-_123"></iframe>"#
      ) == ["ABCdef-_123"]
    )
  }

  @Test internal func dedupesAndIgnoresNonYouTubeLinks() {
    let html = """
      https://www.youtube.com/watch?v=1U3pXddDYo0 and again \
      https://youtu.be/1U3pXddDYo0 plus https://example.com/watch?v=notanid000
      """
    #expect(Import.PodcastCommand.youtubeIDs(in: html) == ["1U3pXddDYo0"])
  }

  @Test internal func emptyWhenNoYouTubeLink() {
    #expect(Import.PodcastCommand.youtubeIDs(in: "no links here").isEmpty)
  }
}
