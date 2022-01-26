//
//  File.swift
//  
//
//  Created by Leo Dion on 1/26/22.
//

import Foundation


extension Product {
  static let heartwitch: Product =
    .init(title: "Heartwitch", description: "Show your heart rate as you live stream with this watch app!", isOpenSource: false, logo: "/media/images/products/heartwitch/logo.svg", style: .square, screenshots: [
      "/media/images/products/heartwitch/watch/002.ActiveWorkout.PNG",
      "/media/images/products/heartwitch/web/001.LoginScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-BOTW-HCG.png",
      "/media/images/products/heartwitch/web/002.CodeScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-RR.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-MC.png",
      "/media/images/products/heartwitch/watch/001.StartWorkout.PNG",
      "/media/images/products/heartwitch/livestream/Heartwitch-BOTW-SMG.png",
      "/media/images/products/heartwitch/web/003.ActiveScreen.png",
      "/media/images/products/heartwitch/livestream/Heartwitch-SMK8D-DKJ.png"

    ], platforms: ["web", "watchOS"], technologies: ["Vapor", "HealthKit", "Heroku", "PostgreSQL"], productURL: "https://heartwitch.app/")
}

enum Products {
  
  static let all : [Product] = [
    .heartwitch,
    Product(
      title: "Portrait",
      description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Commodo odio aenean sed adipiscing diam donec adipiscing tristique.",
      logo: "/media/images/products/sample/logo.jpeg",
      style: .portrait,
      screenshots: [
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg",
        "/media/images/products/sample/screenshot.jpeg"
      ],
      pressCoverage: [
        .init(
          source: "9TO5Mac",
          quote: "It's Greatest App Ever! You must give them your Money!!!",
          url: "https://www.huxley.net/bnw/four.html",
          date: Date(timeIntervalSince1970: 1_445_803_696.0)
        )
      ],
      platforms: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      technologies: ["iPhone", "iPad", "Apple Watch", "Web", "Mac"],
      productURL: "https://google.com",
      githubURL: "https://google.com"
    )
  ]
}
