---
title: Should You SwiftData?
date: 2025-04-08 00:00
description: If you need local storage, Swift has its advantages and disadvantages.
featuredImage: /media/articles/swift-considerations/smartphone-libraries.webp
---

Like many apps at some point you will need some sort of persistent local storage. There are many options and with the release in 2023 of [SwiftData](https://developer.apple.com/documentation/swiftdata) there's some clarity but also confusion around it. [Inspired by Xu Yang's article,](https://fatbobman.com/en/posts/key-considerations-before-using-swiftdata/) In this article, I want to give my own experiences and break down the factors to think about when making that decision. 

## My Journey to SwiftData

I started developing [Bushel](https://getbushel.app) in early 2023 and knew I needed a way to get list of the user's virtual machines, restore images (for installing the OS), snapshots and other entries. My apprehensiveness came from [the format of Core Data](https://brightdigit.com/articles/bushel-launch-part-3/#xcodegen). At this point, I don't want to use an API which uses XML over Swift. I had used Core Data for a client application previously in the early days of Swift 1 and was pretty familiar with using it. Additionally I would consider myself well versed in Relational Databases and SQL, so I am very comfortable working directly with SQLite too.

Eventually [I did go with SwiftData](/articles/bushel-launch-part-2/#swiftdata) and have written about it before:

* [SwiftData CRUD Operations with ModelActor](/tutorials/swiftdata-crud-operations-modelactor/)
* [Being Sendable with SwiftData](/tutorials/swiftdata-sendable/)
* [Using ModelActor in SwiftData](/tutorials/swiftdata-modelactor/)

My reasons for going with SwiftData include:

* I wanted to work within **Apple's confines**
* I saw value in adopting **ORMs**
* I wanted to use **newer technology** in the long term

## Working within Apple's APIs

There are advantages and disadvantages to working within Apple's playground of APIs. Here are a few questions to ask yourself:

### Are you working with technology particular to Apple hardware?

If you are working with a technology that is Apple-centric then it may be best to stick with Apple's API. Over the long term, Apple is good at sticking with that API as hardware changes. If you use a more direct approach, you are dependent on yourself or third-party developers to keep up with updates (see Flutter and React Native).

> youtube https://www.youtube.com/watch?v=uigwEkYklJk

However, there is a small risk that Apple will softly abandon an API. When I say softly abandon, I mean no new WWDC videos, no bug fixes, and no new documentation. For example, [Combine](https://developer.apple.com/documentation/combine) has not had many updates since its release in 2020. This could mean it is no longer the preferred way to interface with SwiftUI (see [Observation](https://developer.apple.com/documentation/observation)). However, in reality, an experienced team in reactive programming which may need to support older OSes sees benefit in adopting this API and it's still the underlying basis for much of SwiftUI. So while adopting Combine now may be riskier, adopting it in 2020 doesn't seem like a bad choice.

A better example are UX-centric APIs such as 3D Touch, WatchKit, complications, visionOS, App Intents and more. These are technologies which were in early infancy and are likely to have a lot of changes.

The other issue is documentation. Apple has improved a lot when it comes to documentation; however, there are blind spots when it comes to certain APIs and not just for abandoned APIs:

* Advanced applications with many integrations 
  * [a great example of this is SwiftUI in dealing with multiple views or navigation as well as the lack of guidance when it comes to testing](/episodes/159-it-depends-with-brandon-williams/)
* Missing unclear definitions of properties, parameters, and usage
* Hidden or difficult to find limitations of abstractions and APIs [such as Web Sockets on watchOS](https://developer.apple.com/documentation/technotes/tn3135-low-level-networking-on-watchos)
* _purposeful agnosticism_

What I mean by _purposeful agnosticism_ is that in some cases **Apple doesn't want to impose a particular pattern** which in many cases makes sense. Developer patterns really depend on [the application, the team, and their skill level.](/articles/ios-software-architecture/)

Having said this, I do highly recommend taking advantage of [forums](https://developer.apple.com/forums/), [sessions](https://developer.apple.com/videos/), [feedback](https://feedbackassistant.apple.com/) and other ways to contact developers at Apple. They are friendly and very helpful when it comes to certain issues.

As a developer _in public_ myself, I'm glad because otherwise we can't sell and publish so many blog posts, courses, videos, and books!

### Are you willing to deal with the challenges of Apple's abstraction?

In some cases, Apple's abstractions can be [more of a challenge than a benefit.](/articles/swiftui-everything-is-possible-if-you-think-like-apple) Personally, I disagree; however, I totally understand the friction other developers run into, especially if you are skilled in a more direct approach:

* Why [SwiftUI](https://developer.apple.com/xcode/swiftui/)? - I know how to interface directly with the UI - [Flutter](https://flutter.dev), [Core Graphics](https://developer.apple.com/documentation/coregraphics), [UIKit](https://developer.apple.com/documentation/uikit), etc...
* Why [SwiftData](https://developer.apple.com/documentation/swiftdata)? - I know how to interface directly with a SQLite Database - [Core Data](https://developer.apple.com/documentation/coredata), [SQLite](https://www.sqlite.org/index.html) libraries
etc...

However, that can come with a risk. More so than Apple abandoning an API, _Apple doesn't care about your direct implementation_. What this means is that if Apple changes hardware - you will need to change your implementation with it. This is especially problematic for UI.

In the early days of iOS development, it was considered reasonable that devices would be the same size forever. However, as device screens grew, iPad was introduced, and new display paradigms were introduced (the notch, dynamic island, etc...). This meant that third-party APIs which assumed consistency had to continually stay up to speed. In the end, it's something to consider when using an API, library or just writing code _closer to the metal_.

## Regarding Local Storage

Before deciding to go with a local storage type, make sure you really need one. [Just as with a backend, if you can avoid it, try to.](/articles/best-backend-for-your-ios-app/) 

* Do you need **offline access**?
* Can you just use a **backend solution**?

Additionally, consider if [User Defaults](https://developer.apple.com/documentation/foundation/userdefaults) might suffice. This was the approach I made with Bushel at first until the release of SwiftData. It was clearly **not the right choice for me** but in some cases, it may be enough.

> transistor https://share.transistor.fm/s/f6092e38

Besides going with an Apple framework or not, here are a few considerations. What is your team well versed or _should be_ well versed in? If you're not a team (i.e., indie application) you have a lot more flexibility, in which case the frequency of maintenance and update of the framework you choose is important. If you and your team are well-versed in SQL and perhaps you want to use the same thing for your Android app, that may make more sense. If your team is very knowledgeable in Core Data, then that might be the way to go. 

We've gone over the reasons to go with Apple's ORM Frameworks vs SQLite. The question next becomes whether you should go with Core Data or SwiftData.

## Core Data vs SwiftData

In regards to SwiftData vs Core Data, it comes down to a few questions:

* How _green_ is your app?
* Are you willing to stick with it and its updates over the years?
* Are you willing to deal with the limitation of abstractions contained within SwiftData?

### Green vs Brown

If you're starting off without any sort of local storage and don't need to support operating systems before 2023 and use SwiftUI, there's very little risk in going with SwiftData. Unless you really don't trust Apple and think that Core Data's more concrete API is required, **I would go with SwiftData.** Much like SwiftUI's adoption, its first releases weren't perfect but going with it in the long term gives many advantages. Those advantages include adoption of new device paradigms and easier hiring for new developers [(see my Objective-C video)](https://www.youtube.com/watch?v=hPSjbD3y_Bs&t=2s). At some point then you may need to update from Core Data to SwiftData [which can be a challenge](/articles/upgrading-old-ios-apps/). SwiftData integrates with many new technologies which Core Data is not even aware of. These include SwiftUI, Macros and of course Swift 6.

### Swift 6, Macros, and SwiftData

One of my biggest complaints with SwiftData is how tightly coupled it is with SwiftUI through [the @Query macro.](https://developer.apple.com/documentation/swiftdata/query()) As I transitioned to [DataThespian](https://github.com/brightdigit/DataThespian) for more of a ModelActor approach in Bushel, I found @Query to either be insufficient or run into conflict with what @Query is doing. At this point, Bushel doesn't even contain @Query properties anymore because of the issues I was running into. 

My point is that at the time of writing of this point, there will be friction as you do more advanced operations - [that's why I wrote a whole library for working with ModelActors.](https://github.com/brightdigit/DataThespian) Dealing with macros for instance, can result in code compilation issues you may need to deep dive to understand. Most of all is [the issues you may run into dealing with Swift 6.](https://www.massicotte.org/model-actor)

> youtube https://www.youtube.com/watch?v=4IoVDpvT5WU

If you are moving to SwiftData, it may be worth considering a move to Swift 6. If you have a fairly large app, perhaps creating a separate Swift 6 module which deals with SwiftData would be worth your time. 

## Alternative Choices

Before closing out, I wanted to post a list of useful Swift Packages:

### I love SQLite

* [groue/GRDB.swift: A toolkit for SQLite databases, with a focus on application development](https://github.com/groue/GRDB.swift)
* [stephencelis/SQLite.swift: A type-safe, Swift-language layer over SQLite3.](https://github.com/stephencelis/SQLite.swift)
* [pointfreeco/sharing-grdb: A lightweight replacement for SwiftData and the Query macro.](https://github.com/pointfreeco/sharing-grdb)
* [groue/GRDBQuery: The SwiftUI companion for GRDB](https://github.com/groue/GRDBQuery)

### I love better abstractions

* [mergesort/Boutique: ✨ A magical persistence library \(and so much more\) for state-driven iOS and Mac apps ✨](https://github.com/mergesort/Boutique)

### I love Core Data

* [JohnEstropia/CoreStore: Unleashing the real power of Core Data with the elegance and safety of Swift](https://github.com/JohnEstropia/CoreStore)

### I love SwiftData

* [fatbobman/SwiftDataKit: SwiftDataKit allows SwiftData developers to access Core Data objects corresponding to SwiftData elements.](https://github.com/fatbobman/SwiftDataKit)
* [brightdigit/DataThespian: Concurrency-Friendly SwiftData](https://github.com/brightdigit/DataThespian)

## Final Thoughts

> youtube https://www.youtube.com/watch?v=rN23Ygvy47E

In the end, I would go with SwiftData. If you are willing to [wait a few months, it could be worth it](https://developer.apple.com/wwdc25/) but my reasons right now are:

* I trust Apple's **long-term commitment** to an API which is used by a plethora of Apps
* I prefer **ORMs** over direct SQL statements
* anything which migrates Xcode non-Swift files to Swift-based code is **preferred** (i.e., 
Storyboards, Core Data Models, Xcode projects)

I'd love to know your thoughts on this. You can reach out to me on [social media](https://brightdigit.com/contact) if you think I'm missing something when it comes to my decision process.