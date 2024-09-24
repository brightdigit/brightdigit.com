---
title: The Great SwiftUI Migration - Part 1 with Ben Scheirman
date: 2024-09-24 08:10
description: Ben Scheirman of NSScreenCast comes on to talk about migrating apps such as a Nike's Sneakers app from UIKit to SwiftUI and all the little things you don't think about. This is part 1 of a 2 part interview.
featuredImage: https://img.transistor.fm/OCCIdzCpTxLGyT-DR0MpB-QrGG5JD-59_s9JIwJtwuo/rs:fill:3000:3000:1/q:60/aHR0cHM6Ly9pbWct/dXBsb2FkLXByb2R1/Y3Rpb24udHJhbnNp/c3Rvci5mbS9kMjcy/ZjZkODdkMDZiOGE3/MzU0ZDYwNjk4ZjZi/YWU2Zi5qcGc.jpg
youtubeID: nI7pn0-tiiQ
audioDuration: 2572
videoDuration: 2823
podcastID: 78f738aa
---
<p>Ben Scheirman of NSScreenCast comes on to talk about migrating apps such as a Nike's Sneakers app from UIKit to SwiftUI and all the little things you don't think about. This is part 1 of a 2 part interview.</p><p><b>Guest</b></p><ul><li><a href="https://benscheirman.com/">Ben Scheirman | Ben is an experienced software engineer from Houston, TX. Currently focused on Swift, iOS, Ruby, and Rust.</a></li><li><a href="https://mastodon.xyz/@bens">Ben Scheirman (@bens@mastodon.xyz) - Mastodon</a></li><li><a href="https://github.com/subdigital">subdigital (Ben Scheirman)</a></li><li><a href="https://nsscreencast.com/episodes">NSScreencast: Bite-sized Screencasts for iOS Development</a></li><li><a href="https://combineswift.com/">Combine Swift</a></li></ul><p><strong>Announcements</strong></p><ul><li><a href="https://brightdigit.com/contact-us/"><strong>Need help with your projects this year? BrightDigit has openings.</strong></a></li><li>Join <a href="https://testflight.apple.com/join/z8xEa2no"><strong>Bushel Beta</strong></a></li><li>Join our <a href="https://patreon.com/brightdigit?utm_medium=clipboard_copy&amp;utm_source=copyLink&amp;utm_campaign=creatorshare_creator&amp;utm_content=join_link"><strong>Brand New Patreon Page!</strong></a></li></ul><p><b>Links</b></p><ul><li><a href="https://www.pointfree.co/episodes/ep288-modern-uikit-stack-navigation-part-2">Episode #288: Modern UIKit: Stack Navigation, Part 2</a></li><li><a href="https://github.com/pointfreeco/swift-perception">pointfreeco/swift-perception: Observable tools, backported.</a></li><li><a href="https://github.com/brightdigit/Sublimation">brightdigit/Sublimation: Enable automatic discovery of your local development server on the fly. Turn your Server-Side Swift app from a mysterious vapor to a tangible solid server.</a></li><li><a href="https://github.com/krzysztofzablocki/LifetimeTracker">krzysztofzablocki/LifetimeTracker: Find retain cycles / memory leaks sooner.</a></li><li><a href="https://github.com/siteline/swiftui-introspect">siteline/swiftui-introspect: Introspect underlying UIKit/AppKit components from SwiftUI</a></li><li><a href="https://vimeo.com/144116310">Presenting Coordinators - Soroush Khanlou on Vimeo</a></li></ul><p><b>Related Episodes</b></p><ul><li><a href="https://brightdigit.com/episodes/182-swiftui-field-guide-with-chris-eidhof/">SwiftUI Field Guide with Chris Eidhof</a></li><li><a href="https://brightdigit.com/episodes/178-sotu-2024-with-peter-witham/">SOTU 2024 with Peter Witham</a></li><li><a href="https://brightdigit.com/episodes/175-swiftui-tips-and-tricks-with-craig-clayton/">SwiftUI Tips and Tricks with Craig Clayton</a></li><li><a href="https://brightdigit.com/episodes/163-swiftly-tooling-with-pol-piella-abadia/">Swiftly Tooling with Pol Piella Abadia</a></li><li><a href="https://brightdigit.com/episodes/159-it-depends-with-brandon-williams/">It Depends with Brandon Williams</a></li><li><a href="https://brightdigit.com/episodes/150-my-taylor-deep-dish-swift-heroes-world-tour/">My Taylor Deep Dish Swift Heroes World Tour</a></li><li><a href="https://brightdigit.com/episodes/142-mobile-system-design-with-tjeerd-in-t-veen/">Mobile System Design with Tjeerd in 't Veen</a></li><li><a href="https://brightdigit.com/episodes/133-the-composable-architecture-with-zev-eisenberg/">The Composable Architecture with Zev Eisenberg</a></li><li><a href="https://brightdigit.com/episodes/135-behind-the-scenes-of-swiftui-with-aviel-gross/">Behind the Scenes of SwiftUI with Aviel Gross</a></li><li><a href="https://brightdigit.com/episodes/125-wwdc-2022-swiftui-and-uikit-with-evan-stone/">WWDC 2022 - SwiftUI and UIKit with Evan Stone</a></li></ul><p><b>Social Media</b></p><p><strong>Email</strong><br>leo@brightdigit.com<br><a href="https://github.com/brightdigit">GitHub - @brightdigit</a></p><p><a href="https://twitter.com/brightdigit"><strong>Twitter </strong><br>BrightDigit - @brightdigit</a><br><a href="https://twitter.com/leogdion">Leo - @leogdion</a></p><p><a href="https://www.linkedin.com/company/bright-digit"><strong>LinkedIn</strong><br>BrightDigit</a><br><a href="https://www.linkedin.com/in/leogdion/">Leo</a></p><p><a href="https://patreon.com/brightdigit?utm_medium=clipboard_copy&amp;utm_source=copyLink&amp;utm_campaign=creatorshare_creator&amp;utm_content=join_link">Patreon - brightdigit</a></p><p><b>Credits</b></p><p><a href="https://filmmusic.io/">Music from https://filmmusic.io</a><br><a href="https://incompetech.com/">"Blippy Trance" by Kevin MacLeod (https://incompetech.com)</a><br><a href="http://creativecommons.org/licenses/by/4.0/">License: CC BY (http://creativecommons.org/licenses/by/4.0/)</a></p>
<ul><li>(00:00) - Who is Ben Scherman</li>
<li>(02:38) - Migrating Apps to Swift UI</li>
<li>(07:03) - Challenges with Swift UI and iOS Versions</li>
<li>(10:24) - Using Introspect for Swift UI</li>
<li>(16:44) - Implementing Collection View in Swift UI</li>
<li>(25:05) - Exploring iOS 18 Scroll View API</li>
<li>(25:30) - SwiftUI vs UIKit: Productivity and Constraints</li>
<li>(26:38) - Design and Engineering Collaboration</li>
<li>(29:43) - Stages of Migrating to SwiftUI</li>
<li>(34:14) - SwiftUI Navigation and Environment Bindings</li>
<li>(39:44) - Retain Cycles and Memory Management</li>
</ul>
<strong>Thanks to our monthly supporters</strong>
<ul>
  <li>Bertram Eber</li>
  <li>Edward Sanchez</li>
  <li>Satoshi Mitsumori</li>
  <li>Danielle Lewis</li>
  <li>Steven Lipton</li>
</ul>
<strong>
  <a href="https://www.patreon.com/brightdigit" rel="payment" title="★ Support this podcast on Patreon ★">★ Support this podcast on Patreon ★</a>
</strong>
      