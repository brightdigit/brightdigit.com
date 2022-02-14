import Foundation

extension Product {
  static let gbeat: Product =
    .init(title: "gBeat", description: """
     Transmit your heart rate data to your fitness instructor or coach in real-time, no matter where you are.

     Founded by fitness & tech enthusiasts looking to solve the problem of having heart rate data for instructors or trainers while they are streaming or coaching classes online.
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
