import Foundation

extension Product {
  static let mistkit: Product =
    .init(
      title: "MistKit",
      description: """
      Swift Package for Service-Side & Command-Line Access to the Apple CloudKit framework

      Use MistKit for

      * Easily migrate data to and from CloudKit
      * Building Command-Line Applications
      * Running apps on non-Apple operating systems
      * Server-side integration (via Vapor)
      * Access serverless computing (via AWS Lambda)
      * And more!
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
      ], platforms: [.watchOS, .web], technologies: [.vapor, .healthkit, .heroku, .postgreSQL], productURL: "https://heartwitch.app/"
    )
}
