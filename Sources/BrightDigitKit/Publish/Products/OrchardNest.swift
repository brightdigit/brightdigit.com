import Foundation

extension Product {
  static let orchardnest: Product =
    .init(title: "OrchardNest", description: """
     Your source for Apple and Swift-related news, tutorials, podcasts, YouTube videos and more!

     OrchardNest aggregates, filters, curates the RSS feeds from developers, designers, podcasters, YouTubers and newsletters in the Apple and Swift development space.
    """, style: .square, screenshots: [
      .at(path: "watch/002.ActiveWorkout.PNG"),
      .at(path: "web/001.LoginScreen.png"),
      .at(path: "livestream/Heartwitch-BOTW-HCG.png"),
      .at(path: "web/002.CodeScreen.png"),
      .at(path: "livestream/Heartwitch-SMK8D-RR.png"),
      .at(path: "livestream/Heartwitch-SMK8D-MC.png"),
      .at(path: "watch/001.StartWorkout.PNG"),
      .at(path: "livestream/Heartwitch-BOTW-SMG.png"),
      .at(path: "web/003.ActiveScreen.png"),
      .at(path: "livestream/Heartwitch-SMK8D-DKJ.png")
    ], platforms: [.watchOS, .web], technologies: [.vapor, .healthkit, .heroku, .postgreSQL], productURL: "https://heartwitch.app/")
}
